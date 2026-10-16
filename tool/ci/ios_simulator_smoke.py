from pathlib import Path
import json, os, signal, subprocess, tempfile, time

out = Path('verification/ios-device')
out.mkdir(parents=True, exist_ok=True)

def run(args, *, seconds=120, save=None):
    print('Native check:', ' '.join(args), flush=True)
    with tempfile.TemporaryFile(mode='w+') as capture:
        proc = subprocess.Popen(args, stdout=capture, stderr=subprocess.STDOUT,
                                text=True, start_new_session=True)
        timed_out = False
        try:
            proc.wait(timeout=seconds)
        except subprocess.TimeoutExpired:
            timed_out = True
            os.killpg(proc.pid, signal.SIGTERM)
            try: proc.wait(timeout=10)
            except subprocess.TimeoutExpired:
                os.killpg(proc.pid, signal.SIGKILL)
                proc.wait(timeout=10)
        capture.seek(0)
        text = capture.read()
    if save: Path(save).write_text(text)
    else: print(text, flush=True)
    if timed_out: raise RuntimeError(f'Native command exceeded {seconds}s: {args[0:3]}')
    if proc.returncode: raise RuntimeError(f'Native command failed ({proc.returncode}): {args[0:3]}')
    return text

# List the already-installed devices. A stalled CoreSimulator service must not
# consume the whole CI job without a diagnostic. One disposable-user restart is
# allowed; metadata firewall, runtime licenses and account settings stay intact.
for attempt in range(2):
    try:
        run(['xcrun', 'simctl', 'list', 'devices', 'available', '--json'],
            seconds=120, save=out/'available-devices.json')
        break
    except RuntimeError:
        if attempt: raise
        print('Restarting only the disposable runner CoreSimulator service once.', flush=True)
        subprocess.run(['killall', 'com.apple.CoreSimulator.CoreSimulatorService'],
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=20)

j = json.loads((out/'available-devices.json').read_text())
candidates = [(runtime, d) for runtime, devices in j['devices'].items()
              if 'iOS-26' in runtime for d in devices
              if d.get('isAvailable') and d['name'].startswith('iPhone')
              and d.get('deviceTypeIdentifier')]
if not candidates:
    raise RuntimeError('No installed iOS 26 iPhone template; no runtime or license was added.')
runtime, template = sorted(candidates, key=lambda item: item[0], reverse=True)[0]
# A new disposable device avoids inherited simulator data from the runner image.
# Use only an installed runtime and device type; keep network isolation intact.
sim = run(['xcrun', 'simctl', 'create', 'Wird-CI-review',
           template['deviceTypeIdentifier'], runtime]).strip()
(out/'selected-simulator.txt').write_text(sim + '\n' + runtime + '\n')

try:
    run(['xcrun','simctl','boot',sim], seconds=120)
    run(['xcrun','simctl','bootstatus',sim,'-b'], seconds=300)
    run(['xcrun','simctl','install',sim,'build/ios/iphonesimulator/Runner.app'])
    run(['xcrun','simctl','io',sim,'screenshot',str(out/'ios-launcher.png')])
    # This is test observation time, never an application startup delay.
    record_log=(out/'startup-recording.log').open('w')
    record=subprocess.Popen(['xcrun','simctl','io',sim,'recordVideo','--codec=h264',str(out/'startup.mp4')],
                            stdout=record_log,stderr=subprocess.STDOUT,start_new_session=True)
    try:
        run(['xcrun','simctl','launch','--terminate-running-process',sim,'ae.wird.app'])
        time.sleep(10)
    finally:
        if record.poll() is None:
            os.killpg(record.pid,signal.SIGINT)
            try: record.wait(timeout=30)
            except subprocess.TimeoutExpired:
                os.killpg(record.pid,signal.SIGTERM)
                record.wait(timeout=10)
        record_log.close()
    run(['xcrun','simctl','io',sim,'screenshot',str(out/'ios-home.png')])
    run(['xcrun','simctl','spawn',sim,'log','show','--last','1m','--style','compact','--predicate',
         'process == "Runner" AND messageType == error'],save=out/'runtime-errors.log')
    errors=(out/'runtime-errors.log').read_text()
    if any(x in errors for x in ['Unhandled Exception','Fatal error','EXC_BAD_ACCESS']):
        raise RuntimeError('iOS runtime error captured')
    import shutil
    if shutil.which('ffmpeg'):
        run(['ffmpeg','-hide_banner','-loglevel','error','-i',str(out/'startup.mp4'),
             '-vf','fps=1/2',str(out/'ios-startup-%02d.png')])
    print('PASS: iOS 26 simulator installation, native launch and actual home-screen capture.',flush=True)
finally:
    try: run(['xcrun','simctl','shutdown',sim],seconds=30)
    except RuntimeError as error: print('Simulator cleanup:', error, flush=True)
