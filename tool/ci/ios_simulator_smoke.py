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
        for attempt in range(2):
            try:
                run(['xcrun','simctl','launch','--terminate-running-process',sim,'ae.wird.app'],
                    seconds=180, save=out/f'launch-attempt-{attempt+1}.log')
                break
            except RuntimeError:
                if attempt: raise
                print('One bounded retry after simulator launch stalled; no app change or account access.', flush=True)
                run(['xcrun','simctl','io',sim,'screenshot',str(out/'ios-launch-retry.png')],seconds=30)
                run(['xcrun','simctl','bootstatus',sim,'-b'],seconds=120)
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
    # Instrumented simulator build exercises the same production Reader widgets.
    # The unsigned device build and ordinary application launch are checked above.
    run(['env', '-i', 'HOME=' + os.environ['RUNNER_TEMP'] + '/wird-home',
         'PATH=' + os.environ['PATH'], 'CI=true', 'LANG=en_US.UTF-8',
         'FLUTTER_SUPPRESS_ANALYTICS=true', 'COCOAPODS_DISABLE_STATS=true',
         'flutter', 'drive', '--driver=test_driver/catalog_driver.dart',
         '--target=integration_test/catalog_device_test.dart', '-d', sim],
        seconds=1200, save=out/'catalog-integration.log')
    # Reuse the native harness against the exact previous production widgets,
    # then restore the reviewed source. Baseline captures have explicit names.
    baseline = '210009a5fac64df097385375c3628d8ad3a7b2cb'
    production = ['lib/main.dart', 'lib/premium_ui.dart']
    current = {p: Path(p).read_bytes() for p in production}
    (out/'home-polish-baseline-source.txt').write_text(baseline + '\n')
    drive = ['env', '-i', 'HOME=' + os.environ['RUNNER_TEMP'] + '/wird-home',
             'PATH=' + os.environ['PATH'], 'CI=true', 'LANG=en_US.UTF-8',
             'FLUTTER_SUPPRESS_ANALYTICS=true', 'COCOAPODS_DISABLE_STATS=true',
             'flutter', 'drive', '--driver=test_driver/home_polish_driver.dart',
             '--target=integration_test/home_polish_device_test.dart', '-d', sim]
    def reset_debug_connection():
        # Sequential Flutter drive builds can leave CoreSimulator's log reader
        # attached to the previous app process. Reboot this disposable device
        # between builds; retain its installed apps and data, and all assertions.
        run(['xcrun', 'simctl', 'shutdown', sim], seconds=60)
        run(['xcrun', 'simctl', 'boot', sim], seconds=120)
        run(['xcrun', 'simctl', 'bootstatus', sim, '-b'], seconds=300)

    try:
        for path in production:
            Path(path).write_bytes(subprocess.check_output(['git', 'show', f'{baseline}:{path}']))
        reset_debug_connection()
        run(drive + ['--dart-define=WIRD_BASELINE_RENDER=true'], seconds=1200,
            save=out/'home-polish-before.log')
    finally:
        for path, content in current.items(): Path(path).write_bytes(content)
    reset_debug_connection()
    run(drive, seconds=1200, save=out/'home-polish-after.log')
    print('PASS: iOS 26 simulator installation, native launch, both-theme Home/navigation and 200% text.',flush=True)
finally:
    try: run(['xcrun','simctl','shutdown',sim],seconds=30)
    except RuntimeError as error: print('Simulator cleanup:', error, flush=True)


