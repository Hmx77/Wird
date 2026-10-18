"""Actual emulator navigation checks using observed accessibility node bounds."""
import json
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

def tap(label, scroll=False, bottom=False):
    for attempt in range(7 if scroll else 3):
        candidates = []
        for n in snapshot():
            value = n.get('text', '') + ' ' + n.get('content-desc', '')
            if normal(label) not in normal(value):
                continue
            bounds = list(map(int, re.findall(r'\d+', n.get('bounds', ''))))
            if len(bounds) != 4:
                continue
            x1, y1, x2, y2 = bounds
            if x2 <= x1 or y2 <= y1 or y1 < 0 or y2 > height:
                continue
            if scroll and y2 > height * .89:
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
        if normal(label) in normal(value):
            return
        time.sleep(1)
    raise AssertionError(f'Destination missing: {label}')

def capture(name):
    raw = adb('exec-out','screencap','-p',binary=True)
    assert raw.startswith(b'\x89PNG\r\n\x1a\n')
    (out/name).write_bytes(raw)

checks=[]
for label, count in [('أذكار الصباح',18),('أذكار المساء',15),('أذكار النوم',16)]:
    tap(label,scroll=True)
    expect(f'1 / {count}')
    checks.append(label)
    adb('shell','input','keyevent','KEYCODE_BACK')
    expect('الرئيسية')
# Scroll to the real shortcut row, then exercise tabs, favorites and counter.
tap('جميع الأذكار',scroll=True)
expect('ابحث واقرأ واحفظ أذكارك المفضلة')
checks.append('all-collections')
tap('الرئيسية',bottom=True)
tap('المفضلة',scroll=True)
expect('لا توجد نتائج')
checks.append('favorites-empty-offline')
adb('shell','input','keyevent','KEYCODE_BACK')
tap('التسبيح',scroll=True)
expect('السبحة الشخصية')
tap('تسبيح +')
expect('1')
checks.append('personal-counter')
adb('shell','input','keyevent','KEYCODE_BACK')
capture('android-home-shortcuts.png')
tap('النوافل',scroll=True)
expect('السنن الرواتب الاثنتا عشرة')
capture('android-nawafil-navigation.png')
checks.append('nawafil-shortcut-and-sujood-navigation')
tap('الإعدادات',bottom=True)
expect('المظهر والقراءة والخصوصية')
checks.append('settings-navigation')
tap('الرئيسية',bottom=True)
# Restore the home to the top for later captures and comparisons.
adb('shell','input','swipe',str(width//2),str(int(height*.3)),str(width//2),str(int(height*.79)),'450')
adb('shell','input','swipe',str(width//2),str(int(height*.3)),str(width//2),str(int(height*.79)),'450')
expect('وردك اليومي')
(out/'premium-home-navigation.json').write_text(json.dumps({'passed':checks,'offline':True},ensure_ascii=False,indent=2)+'\n')
print('PASS: actual Android premium home categories, shortcuts, counter and navigation:',len(checks))
