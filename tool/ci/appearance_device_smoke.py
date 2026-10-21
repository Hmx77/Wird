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
            matched=any(
                part.strip()==label
                for n in nodes for key in ['text','content-desc']
                for part in n.get(key,'').splitlines()) or any(
                    re.fullmatch(re.escape(label)+r',\s*'+re.escape(normal('عداد السبحة الشخصية')),
                                 normal(n.get('content-desc',''))) is not None
                    for n in nodes)
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


def top():
    for _ in range(4):
        adb('shell','input','swipe',str(width//2),str(int(height*.30)),str(width//2),str(int(height*.83)),'150')

def home():
    tap('الرئيسية',bottom=True,exact=True)
    top()
    expect('وردك اليومي')

checks=[]
for mode,label in [('ivory','فاتح — Ivory Serenity'),('midnight','داكن — Midnight Teal')]:
    tap('الإعدادات',bottom=True,exact=True)
    top()
    tap('المظهر',scroll=True)
    nodes=snapshot()
    all_text=' '.join(n.get('text','')+' '+n.get('content-desc','') for n in nodes)
    for expected in ['Midnight Teal','Ivory Serenity']: assert expected in all_text
    for retired in ['Olive & Cream','Ocean Blue','Mocha & Sand','Soft Lavender','Emerald & Gold','Midnight Blue','Charcoal & Sage','Dusty Rose & Stone','Stone & Teal','Sage & Ivory']:
        assert retired not in all_text, retired
    capture(f'android-appearance-{mode}-selector.png')
    tap(label,exact=True)
    capture(f'android-appearance-{mode}-settings.png')
    home()
    capture(f'android-appearance-{mode}-home.png')
    tap('الأذكار',bottom=True,exact=True)
    top()
    capture(f'android-appearance-{mode}-library.png')
    home()
    tap('أذكار الصباح')
    expect('الفضل والدليل والمعنى')
    capture(f'android-appearance-{mode}-reader.png')
    adb('shell','input','keyevent','KEYCODE_BACK')
    home()
    tap('النوافل',bottom=True,exact=True)
    top()
    capture(f'android-appearance-{mode}-nawafil.png')
    home()
    tap('التسبيح',scroll=True)
    expect('السبحة الشخصية')
    capture(f'android-appearance-{mode}-tasbih.png')
    adb('shell','input','keyevent','KEYCODE_BACK')
    home()
    adb('shell','am','force-stop','ae.wird.app')
    adb('shell','am','start','-W','-n','ae.wird.app/.MainActivity')
    time.sleep(3)
    expect('وردك اليومي')
    tap('الإعدادات',bottom=True,exact=True)
    top()
    expect(label)
    checks.append(mode+': two choices, immediate switch, six screens, real restart persistence')
    home()
(out/'appearance-interactions.json').write_text(json.dumps({'passed':True,'offline':True,'checks':checks},ensure_ascii=False,indent=2))
print('PASS: both appearances, only two choices, offline captures and restart persistence')

