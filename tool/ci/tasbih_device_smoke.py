"""Actual emulator navigation checks using observed accessibility node bounds."""
import json
import math
from pathlib import Path
import re
import subprocess
import time
import unicodedata
import xml.etree.ElementTree as ET

out = Path('verification/device')

def adb(*args, binary=False):
    return subprocess.check_output(['adb', *args], timeout=25, text=not binary)

def normal(text):
    return ''.join(c for c in unicodedata.normalize('NFD', text) if unicodedata.category(c) != 'Mn')

def snapshot():
    adb('shell', 'uiautomator', 'dump', '/sdcard/wird-home-review.xml')
    xml = adb('shell', 'cat', '/sdcard/wird-home-review.xml')
    (out / 'premium-home-last.xml').write_text(xml)
    return list(ET.fromstring(xml).iter('node'))

size = re.findall(r'(\d+)x(\d+)', adb('shell', 'wm', 'size'))[-1]
width, height = map(int, size)

def tap(label, scroll=False, bottom=False, exact=False, node_class=None, allow_bottom=False, prefix=False):
    for attempt in range(50 if scroll else 3):
        candidates = []
        for n in snapshot():
            value = n.get('text', '') + ' ' + n.get('content-desc', '') + ' ' + n.get('hint', '')
            if node_class and n.get('class') != node_class:
                continue
            values = [n.get(k, '') for k in ['text', 'content-desc', 'hint']]
            if prefix and not any(normal(v).strip().startswith(normal(label)) for v in values):
                continue
            if (exact and not any(normal(label) == normal(v) for v in values)) or (not exact and normal(label) not in normal(value)):
                continue
            bounds = list(map(int, re.findall(r'\d+', n.get('bounds', ''))))
            if len(bounds) != 4:
                continue
            x1, y1, x2, y2 = bounds
            if x2 <= x1 or y2 <= y1 or y1 < 0 or y2 > height:
                continue
            if scroll and y2 > height * (.98 if allow_bottom else .89):
                continue
            candidates.append((n, bounds))
        if candidates:
            candidates.sort(key=lambda pair: pair[1][1] if bottom else -(pair[1][2]-pair[1][0])*(pair[1][3]-pair[1][1]), reverse=True)
            _, (x1,y1,x2,y2) = candidates[0]
            adb('shell','input','tap',str((x1+x2)//2),str((y1+y2)//2))
            return
        if scroll:
            adb('shell','input','swipe',str(width//2),str(int(height*.77)),str(width//2),str(int(height*.32)),'450')
        else:
            time.sleep(1)
    raise AssertionError(f'No visible target: {label}')

def expect(label):
    for _ in range(6):
        nodes = snapshot()
        value = ' '.join(n.get('text','') + ' ' + n.get('content-desc','') for n in nodes)
        if label.isdecimal():
            matched=any(part.strip()==label for n in nodes for key in ['text','content-desc'] for part in n.get(key,'').splitlines())
        else:
            matched=normal(label) in normal(value)
        if matched:
            return
        time.sleep(1)
    raise AssertionError(f'Destination missing: {label}')

def capture(name):
    raw = adb('exec-out','screencap','-p',binary=True)
    assert raw.startswith(b'\x89PNG\r\n\x1a\n')
    (out/name).write_bytes(raw)

# Actual offline UI. Religious content is never extracted from the mockups.
# This script follows the existing Home and Reader regression suites.
checks=[]
tap('التسبيح',scroll=True)
expect('السبحة الشخصية')
tap('إعادة',exact=True)
expect('0')
capture('android-tasbih-zero.png')
# Recording covers real native controls and app restart, not a mockup.
record=subprocess.Popen(['adb','shell','screenrecord','--time-limit','170','/sdcard/tasbih-interactions.mp4'],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
for i in range(6): tap('تسبيح +',exact=True)
expect('6');capture('android-tasbih-six.png')
checks.append('six individual taps => 6')
# Locate the actual accessible counting button before sending a rapid batch.
nodes=snapshot()
button=next(n for n in nodes if any(normal(n.get(k,'')).strip()==normal('تسبيح +') for k in ['text','content-desc']))
x1,y1,x2,y2=map(int,re.findall(r'\d+',button.get('bounds','')))
x,y=(x1+x2)//2,(y1+y2)//2
adb('shell','; '.join([f'input tap {x} {y}']*25))
expect('31');capture('android-tasbih-rapid.png');checks.append('25 rapid native taps => 31')
adb('shell','am','force-stop','ae.wird.app');adb('shell','am','start','-W','-n','ae.wird.app/.MainActivity')
expect('الرئيسية');tap('التسبيح',scroll=True);expect('31')
capture('android-tasbih-persisted.png');checks.append('31 survives actual process restart')
tap('إعادة',exact=True);expect('0');capture('android-tasbih-reset.png')
checks.append('reset clears personal count only')
adb('shell','settings','put','system','font_scale','2.0')
time.sleep(2)
capture('android-tasbih-large-text.png')
tap('تسبيح +',scroll=True,exact=True,allow_bottom=True);expect('1')
tap('إعادة',scroll=True,exact=True,allow_bottom=True);expect('0')
checks.append('200% system text: scrollable increment/reset')
adb('shell','settings','put','system','font_scale','1.0')
adb('shell','wm','size','640x1136');adb('shell','wm','density','320');time.sleep(2)
capture('android-tasbih-small.png')
tap('تسبيح +',scroll=True,exact=True,allow_bottom=True);expect('1')
tap('إعادة',scroll=True,exact=True,allow_bottom=True);expect('0')
checks.append('320dp small-phone native layout and controls')
adb('shell','wm','size','reset');adb('shell','wm','density','reset')
adb('shell','input','keyevent','KEYCODE_BACK');expect('الرئيسية')
adb('shell','pkill','-INT','screenrecord')
record.wait(timeout=20)
adb('pull','/sdcard/tasbih-interactions.mp4',str(out/'tasbih-interactions.mp4'))
(out/'tasbih-interactions.json').write_text(json.dumps({'passed':True,'offline':True,'checks':checks,'haptics':'platform-channel true/false widget tests; physical feel needs device review'},ensure_ascii=False,indent=2)+'\n')
print('PASS: native personal Tasbih',checks,flush=True)
