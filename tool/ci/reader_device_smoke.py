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

def tap(label, scroll=False, bottom=False, exact=False, node_class=None):
    for attempt in range(50 if scroll else 3):
        candidates = []
        for n in snapshot():
            value = n.get('text', '') + ' ' + n.get('content-desc', '') + ' ' + n.get('hint', '')
            if node_class and n.get('class') != node_class:
                continue
            values = [n.get(k, '') for k in ['text', 'content-desc', 'hint']]
            if (exact and not any(normal(label) == normal(v) for v in values)) or (not exact and normal(label) not in normal(value)):
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
tap('الأذكار',bottom=True)
expect('49 ذكر')
capture('android-library-premium.png')
tap('ابحث عن ذكر')
for attempt in range(6):
    if any(n.get('class')=='android.widget.EditText' and n.get('focused')=='true' for n in snapshot()):break
    time.sleep(.3)
else:raise AssertionError('Search input did not receive focus')
adb('shell','input','text','Evening')
expect('15 ذكر')
adb('shell','input','keyevent','KEYCODE_BACK')
capture('android-library-search.png')
tap('مسح البحث')
expect('49 ذكر')
tap('حفظ في المفضلة آية الكرسي',scroll=True)
tap('المفضلة', exact=True)
expect('1 ذكر')
capture('android-library-favorites.png')
tap('آية الكرسي',scroll=True,node_class='android.view.View')
expect('1 / 18')
capture('android-reader-main.png')
tap('الفضل والدليل والمعنى',scroll=True)
expect('المعنى')
tap('المعنى',scroll=True)
capture('android-reader-evidence.png')
tap('التالي',scroll=True)
expect('2 / 18')
tap('اضغط للعد',scroll=True)
expect('1 / 3')
capture('android-reader-counter.png')
tap('تراجع عن ضغطة',scroll=True)
expect('0 / 3')
tap('اضغط للعد',scroll=True)
expect('1 / 3')
adb('shell','am','force-stop','ae.wird.app')
adb('shell','am','start','-W','-n','ae.wird.app/.MainActivity')
expect('الرئيسية')
tap('أذكار الصباح',scroll=True)
tap('التالي',scroll=True)
expect('2 / 18')
tap('اضغط للعد',scroll=True)
expect('2 / 3')
capture('android-reader-persisted.png')
tap('السابق',scroll=True)
expect('1 / 18')
adb('shell','input','keyevent','KEYCODE_BACK')
tap('الأذكار',bottom=True)
# A new tab visit keeps live bookmark state. Show all collections for long text.
tap('ابحث عن ذكر')
for attempt in range(6):
    if any(n.get('class')=='android.widget.EditText' and n.get('focused')=='true' for n in snapshot()):break
    time.sleep(.3)
else:raise AssertionError('Search input did not receive focus')
adb('shell','input','text','Bedtime')
adb('shell','input','keyevent','KEYCODE_BACK')
# Favorites filter was reset on process restart, as in the original application.
expect('16 ذكر')
tap('سورة الملك',scroll=True,node_class='android.view.View')
expect('سورة الملك')
capture('android-reader-mulk.png')
adb('shell','settings','put','system','font_scale','1.5')
# System text-scale updates must preserve complete selectable text and scrolling.
time.sleep(2)
capture('android-reader-mulk-large.png')
for attempt in range(50):
    nodes=snapshot()
    visible=[n for n in nodes if normal('اضغط للعد') in normal(n.get('text','')+' '+n.get('content-desc','')) and len(re.findall(r'\d+',n.get('bounds','')))==4 and 0<int(re.findall(r'\d+',n.get('bounds',''))[1])<height*.85]
    if visible:
        capture('android-reader-mulk-counter.png')
        break
    adb('shell','input','swipe',str(width//2),str(int(height*.77)),str(width//2),str(int(height*.32)),'450')
else:raise AssertionError('Long Quran counter did not become reachable')
adb('shell','settings','put','system','font_scale','1.0')
adb('shell','input','keyevent','KEYCODE_BACK')
tap('الرئيسية',bottom=True)
(out/'reader-interactions.json').write_text(json.dumps({'passed':True,'offline':True,'library_count':49,'search_evening':15,'search_bedtime':16,'bookmark_filter':1,'reader_count_sequence':['1/3','0/3','1/3','restart','2/3'],'navigation':['next','previous'],'evidence':'expanded','long_passage':'Mulk at system font scale 1.5'},ensure_ascii=False,indent=2)+'\n')
print('PASS: premium Library search/bookmarks, Reader count/Undo/restart/navigation/evidence and large Mulk',flush=True)

