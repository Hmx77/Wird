"""Actual Android before/after captures and a same-key previous-source upgrade.

Only disposable emulator test data is used. No uninstall or data clearing.
"""
from pathlib import Path
import hashlib
import json
import os
import re
import subprocess
import time
import unicodedata
import xml.etree.ElementTree as ET
from native_targets import content_bottom, usable_target

out = Path('verification/device')
baseline = Path('build/upgrade-baseline/app-debug.apk')
current = Path('build/app/outputs/flutter-apk/app-debug.apk')
base_sha = Path('build/upgrade-baseline/source-commit.txt').read_text().strip()
assert base_sha == '210009a5fac64df097385375c3628d8ad3a7b2cb'
source = subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip()

def adb(*args, binary=False):
    return subprocess.check_output(['adb', *args], text=not binary, timeout=60)

def normal(value):
    return ''.join(c for c in unicodedata.normalize('NFD', value) if unicodedata.category(c) != 'Mn')

def nodes():
    # UIAutomator can briefly have no root while Flutter changes routes.
    # Never accept a stale dump from the preceding screen.
    for attempt in range(5):
        adb('shell', 'rm', '-f', '/sdcard/wird-polish.xml')
        result = adb('shell', 'uiautomator', 'dump', '/sdcard/wird-polish.xml')
        if 'dumped to' in result:
            return list(ET.fromstring(adb('shell', 'cat', '/sdcard/wird-polish.xml')).iter('node'))
        time.sleep(1)
    raise AssertionError('UIAutomator could not capture the current screen')

def dimensions():
    return tuple(map(int, re.findall(r'(\d+)x(\d+)', adb('shell', 'wm', 'size'))[-1]))

def target(label, scroll=False, bottom=False, center=False):
    width, height = dimensions()
    for _ in range(40 if scroll else 8):
        current_nodes = nodes()
        limit = height if bottom else content_bottom(current_nodes, height)
        matches = []
        for n in current_nodes:
            if n.get('clickable') != 'true': continue
            value = normal(n.get('text', '') + ' ' + n.get('content-desc', ''))
            if normal(label) not in value: continue
            b = list(map(int, re.findall(r'-?\d+', n.get('bounds', ''))))
            if len(b) != 4 or not usable_target(b, limit): continue
            matches.append((n, b))
        if matches:
            matches.sort(key=lambda pair: pair[1][1] if bottom else
                (pair[1][2]-pair[1][0])*(pair[1][3]-pair[1][1]), reverse=True)
            node, b = matches[0]
            if center and not height*.12 <= b[1] <= height*.28:
                delta = int(b[1] - height*.20)
                start = int(limit*.70 if delta > 0 else height*.25)
                end = max(100, min(int(limit-30), start-delta))
                adb('shell','input','swipe',str(width//2),str(start),str(width//2),str(end),'450')
                time.sleep(.5)
                continue
            return node, b
        if scroll:
            adb('shell','input','swipe',str(width//2),str(int(limit*.9)),str(width//2),str(int(height*.28)),'450')
        else: time.sleep(1)
    capture('android-polish-target-failure.png')
    raise AssertionError('Native polish target missing: ' + label)

def tap(label, **options):
    _, (x1,y1,x2,y2) = target(label, **options)
    adb('shell','input','tap',str((x1+x2)//2),str((y1+y2)//2))
    time.sleep(.6)

def top():
    width, height = dimensions()
    for _ in range(12):
        adb('shell','input','swipe',str(width//2),str(int(height*.28)),str(width//2),str(int(height*.78)),'150')

def home():
    tap('الرئيسية', bottom=True)
    top()

def capture(name):
    time.sleep(1)
    raw = adb('exec-out','screencap','-p',binary=True)
    assert raw.startswith(b'\x89PNG\r\n\x1a\n')
    (out/name).write_bytes(raw)

def preferences():
    xml = adb('shell','run-as','ae.wird.app','cat','shared_prefs/FlutterSharedPreferences.xml')
    return {n.get('name'): ET.tostring(n, encoding='unicode') for n in ET.fromstring(xml)}

def replace_and_launch(apk):
    adb('shell','am','force-stop','ae.wird.app')
    response = adb('install','--no-streaming','-r',str(apk))
    assert 'Success' in response, response
    adb('shell','am','start','-W','-n','ae.wird.app/.MainActivity')
    time.sleep(4)
    target('الرئيسية', bottom=True)

labels = ['الرئيسية', 'الأذكار', 'النوافل', 'الإعدادات']

def review(stage):
    for mode, label in [('midnight','Midnight Teal'), ('ivory','Ivory Serenity')]:
        tap('الإعدادات', bottom=True); top()
        tap('المظهر', scroll=True); tap(label)
        home()
        capture(f'android-{stage}-{mode}-home.png')
        if stage == 'after':
            for index, destination in enumerate(labels):
                tap(destination, bottom=True)
                selected = [target(name, bottom=True)[0].get('selected') == 'true' for name in labels]
                assert selected == [i == index for i in range(4)], (destination, selected)
                capture(f'android-{stage}-{mode}-tab-{index}.png')
        try:
            adb('shell','wm','size','640x1136'); adb('shell','wm','density','320')
            adb('shell','settings','put','system','font_scale','2.0')
            time.sleep(2); home()
            capture(f'android-{stage}-{mode}-text200-home.png')
            for section, label in [('morning','أذكار الصباح'),('evening','أذكار المساء'),('sleep','أذكار النوم')]:
                home(); target(label, scroll=True, center=True)
                capture(f'android-{stage}-{mode}-text200-{section}.png')
            if stage == 'after':
                for label in labels:
                    _, b = target(label, bottom=True)
                    assert b[2]-b[0] >= 96 and b[3]-b[1] >= 96, (label, b)
        finally:
            adb('shell','settings','put','system','font_scale','1.0')
            adb('shell','wm','size','reset'); adb('shell','wm','density','reset')
            time.sleep(2); home()

# The previous and final app are built with the same disposable CI debug key.
# This verifies a real source upgrade; it cannot repair keys from prior runners.
signer = sorted(Path(os.environ['ANDROID_HOME']).glob('build-tools/*/apksigner'))[-1]
def certificate(apk):
    result = subprocess.check_output([str(signer),'verify','--print-certs',str(apk)],text=True)
    # New build-tools include the signer's SDK range in this line. Match the
    # certificate field rather than its version-dependent signer prefix.
    name = 'baseline' if apk == baseline else 'current'
    (out/f'apksigner-{name}.txt').write_text(result)
    fingerprints = set(re.findall(r'certificate SHA-256 digest:\s*([0-9a-fA-F]{64})\b', result))
    assert len(fingerprints) == 1, f'Expected one signing certificate for {name}: {result}'
    return fingerprints.pop().lower()
assert certificate(baseline) == certificate(current), 'Upgrade fixture must share the current APK signing key'
saved = preferences()
replace_and_launch(baseline)
assert preferences() == saved, 'Previous source did not preserve the native fixture'
review('before')
before_upgrade = preferences()
(out/'upgrade-preferences-before.json').write_text(json.dumps(before_upgrade,ensure_ascii=False,indent=2))
replace_and_launch(current)
after_upgrade = preferences()
assert after_upgrade == before_upgrade, 'Actual APK upgrade altered stored data'
(out/'upgrade-preferences-after.json').write_text(json.dumps(after_upgrade,ensure_ascii=False,indent=2))
review('after')
report = {'passed':True,'previousSource':base_sha,'source':source,
    'apkSHA256':hashlib.sha256(current.read_bytes()).hexdigest(),
    'sameCertificate':certificate(current),'installMode':'adb install -r; no uninstall/data clear',
    'allStoredKeysPreserved':sorted(before_upgrade),'beforeAfterCaptured':True,
    'themes':2,'normalAnd200Percent':True,'selectedTabsVerified':4,
    'priorDistributedDebugCertificateCompatibility':'Not implied; earlier CI keys differ'}
(out/'home-polish-upgrade.json').write_text(json.dumps(report,ensure_ascii=False,indent=2))
print('PASS: actual previous-source APK upgrade retained all stored data; both-theme Home/navigation/200% captures',flush=True)
