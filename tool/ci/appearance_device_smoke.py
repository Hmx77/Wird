"""Actual emulator navigation checks using observed accessibility node bounds."""
import json
from native_targets import content_bottom as visible_bottom, usable_target
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

def content_bottom(nodes):
    return visible_bottom(nodes, height)

def scroll_content(nodes):
    bottom = content_bottom(nodes)
    adb('shell','input','swipe',str(width//2),str(int(bottom * .9)),
        str(width//2),str(int(height * .28)),'450')

def tap(label, scroll=False, bottom=False, exact=False, node_class=None, allow_bottom=False, prefix=False, clickable=False, capture_before=None):
    for attempt in range(50 if scroll else 3):
        candidates = []
        nodes = snapshot()
        limit = height * .98 if allow_bottom else content_bottom(nodes)
        for n in nodes:
            value = n.get('text', '') + ' ' + n.get('content-desc', '') + ' ' + n.get('hint', '')
            if node_class and n.get('class') != node_class:
                continue
            if clickable and n.get('clickable') != 'true':
                continue
            values = [n.get(k, '') for k in ['text', 'content-desc', 'hint']]
            if prefix and not any(normal(v).strip().startswith(normal(label)) for v in values):
                continue
            if (exact and not any(normal(label) == normal(v) for v in values)) or (not exact and normal(label) not in normal(value)):
                continue
            bounds = list(map(int, re.findall(r'-?\d+', n.get('bounds', ''))))
            if len(bounds) != 4:
                continue
            x1, y1, x2, y2 = bounds
            if x2 <= x1 or y2 <= y1 or y1 < 0 or y2 > height:
                continue
            if scroll and not usable_target((x1,y1,x2,y2), limit):
                continue
            candidates.append((n, bounds))
        if candidates:
            candidates.sort(key=lambda pair: pair[1][1] if bottom else -(pair[1][2]-pair[1][0])*(pair[1][3]-pair[1][1]), reverse=True)
            _, (x1,y1,x2,y2) = candidates[0]
            if capture_before:
                capture(capture_before)
            adb('shell','input','tap',str((x1+x2)//2),str((y1+y2)//2))
            time.sleep(.4)
            return
        if scroll:
            scroll_content(nodes)
        else:
            time.sleep(1)
    capture('android-appearance-target-failure.png')
    (out/'appearance-target-failure.xml').write_text(adb('shell','cat','/sdcard/wird-home-review.xml'))
    raise AssertionError(f'No visible target: {label}')

def expect(label, scroll=False):
    for _ in range(20 if scroll else 6):
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
        if scroll:
            scroll_content(nodes)
        time.sleep(1)
    capture('android-appearance-expect-failure.png')
    raise AssertionError(f'Destination missing: {label}')

def capture(name):
    # ADB input returns before Flutter's route/theme animations have finished.
    # Capture only after the transition has settled, not the outgoing modal.
    time.sleep(1)
    raw = adb('exec-out','screencap','-p',binary=True)
    assert raw.startswith(b'\x89PNG\r\n\x1a\n')
    (out/name).write_bytes(raw)


def top():
    for _ in range(16):
        adb('shell','input','swipe',str(width//2),str(int(height*.30)),str(width//2),str(int(height*.83)),'150')

def home():
    # A popped Reader and a system font-scale change can still be animating
    # while the underlying Library's accessibility nodes are already exposed.
    # Wait for that transition, then use freshly observed clickable tab bounds.
    for attempt in range(3):
        time.sleep(1)
        nodes = snapshot()
        home_visible = any(normal('الرئيسية') in normal(n.get('text', '') + ' ' + n.get('content-desc', ''))
                           and n.get('clickable') == 'true' for n in nodes)
        if not home_visible:
            # A quick system Back after dismissing a native share sheet may
            # be consumed by its closing animation. Use the visible Reader
            # back button instead of assuming the shell is already exposed.
            reader_back = any(normal(n.get('content-desc', '')).strip() == normal('رجوع')
                              and n.get('clickable') == 'true' for n in nodes)
            if reader_back:
                tap('رجوع', exact=True, clickable=True)
                time.sleep(1)
                continue
        tap('الرئيسية', bottom=True, clickable=True)
        time.sleep(1)
        top()
        nodes = snapshot()
        text = ' '.join(n.get('text', '') + ' ' + n.get('content-desc', '') for n in nodes)
        if normal('وردك اليومي') in normal(text):
            return
        (out / f'home-transition-attempt-{attempt + 1}.xml').write_text(
            adb('shell', 'cat', '/sdcard/wird-home-review.xml'))
    expect('وردك اليومي')

def worship_preferences():
    xml = adb('shell','run-as','ae.wird.app','cat','shared_prefs/FlutterSharedPreferences.xml')
    return {node.get('name'): ET.tostring(node,encoding='unicode')
            for node in ET.fromstring(xml)
            if node.get('name') != 'flutter.appearance.v2'}

checks=[]
for mode,label in [('ivory','Ivory Serenity'),('midnight','Midnight Teal')]:
    print('START: native appearance and reference checks', mode, flush=True)
    original_preferences = worship_preferences()
    tap('الإعدادات',bottom=True)
    top()
    tap('المظهر',scroll=True,clickable=True)
    nodes=snapshot()
    all_text=' '.join(n.get('text','')+' '+n.get('content-desc','') for n in nodes)
    for expected in ['Midnight Teal','Ivory Serenity']: assert expected in all_text
    for retired in ['Olive & Cream','Ocean Blue','Mocha & Sand','Soft Lavender','Emerald & Gold','Midnight Blue','Charcoal & Sage','Dusty Rose & Stone','Stone & Teal','Sage & Ivory']:
        assert retired not in all_text, retired
    tap(label)
    capture(f'android-appearance-{mode}-settings.png')
    tap('المظهر',scroll=True,clickable=True)
    capture(f'android-appearance-{mode}-selector.png')
    adb('shell','input','keyevent','KEYCODE_BACK')
    tap('التفاصيل والمصادر',scroll=True)
    expect('لا حسابات ولا إعلانات')
    capture(f'android-appearance-{mode}-settings-privacy.png')
    tap('مسح بياناتي المحلية',scroll=True)
    expect('مسح المتابعة والمفضلة؟')
    capture(f'android-appearance-{mode}-delete-confirmation.png')
    tap('إلغاء')
    capture(f'android-appearance-{mode}-settings-bottom.png')
    assert not any('تراخيص البرمجيات' in (n.get('text','') + n.get('content-desc','')) for n in snapshot())
    # Samsung-sized viewport, both themes, scrollable sheet and real choice.
    saved_size = (width, height)
    try:
        adb('shell','wm','size','640x1136')
        adb('shell','wm','density','320')
        width, height = 640, 1136
        time.sleep(2)
        top()
        capture(f'android-{mode}-settings-320dp.png')
        tap('المظهر',scroll=True,clickable=True)
        capture(f'android-{mode}-selector-320dp.png')
        tap(label,scroll=True,allow_bottom=True)
        adb('shell','settings','put','system','font_scale','2.0')
        time.sleep(2)
        top()
        tap('المظهر',scroll=True,clickable=True)
        capture(f'android-{mode}-selector-320dp-text200.png')
        tap(label,scroll=True,allow_bottom=True)
    finally:
        adb('shell','settings','put','system','font_scale','1.0')
        adb('shell','wm','size','reset')
        adb('shell','wm','density','reset')
        width, height = saved_size
        time.sleep(2)
    home()
    capture(f'android-appearance-{mode}-home.png')
    if mode == 'ivory':
        # Check the changed visible surfaces actually navigate, not just render.
        for section in ['أذكار المساء', 'أذكار النوم']:
            tap(section, scroll=True)
            expect('الفضل والدليل والمعنى', scroll=True)
            adb('shell','input','keyevent','KEYCODE_BACK')
            home()
        tap('لحظات من السكينة', scroll=True)
        expect('الفضل والدليل والمعنى', scroll=True)
        adb('shell','input','keyevent','KEYCODE_BACK')
        home()
        tap('ابحث عن ذكر')
        expect('الأذكار')
        adb('shell','input','keyevent','KEYCODE_BACK')
        home()
        tap('المفضلة', scroll=True)
        expect('المفضلة')
        adb('shell','input','keyevent','KEYCODE_BACK')
        home()
        tap('جميع الأذكار', scroll=True)
        expect('الأذكار')
        home()
        tap('النوافل', scroll=True)
        expect('النوافل')
        home()
        checks.append('Ivory Home: Continue, Evening, Bedtime, Search, Favorites, All Athkar and Nawafil navigation')
        # Exercise the new Home at 320dp, independently of the dark startup pass.
        original_size = (width, height)
        try:
            adb('shell', 'wm', 'size', '640x1136')
            adb('shell', 'wm', 'density', '320')
            width, height = 640, 1136
            time.sleep(2)
            home()
            capture('android-ivory-home-320dp-top.png')
            tap('أذكار الصباح', scroll=True)
            expect('الفضل والدليل والمعنى', scroll=True)
            adb('shell','input','keyevent','KEYCODE_BACK')
            home()
            adb('shell','input','swipe','320','900','320','300','450')
            capture('android-ivory-home-320dp-bottom.png')
            tap('التسبيح', scroll=True)
            expect('السبحة الشخصية')
            adb('shell','input','keyevent','KEYCODE_BACK')
            adb('shell','settings','put','system','font_scale','2.0')
            time.sleep(2)
            home()
            capture('android-ivory-home-320dp-text200-top.png')
            for section, slug in [('أذكار الصباح', 'morning'), ('أذكار المساء', 'evening')]:
                home()
                tap(section, scroll=True, capture_before=f'android-ivory-{slug}-320dp-text200.png')
                expect('الفضل والدليل والمعنى', scroll=True)
                adb('shell','input','keyevent','KEYCODE_BACK')
            checks.append('Ivory Home: 320dp, 200% text, Morning/Evening and Tasbih navigation')
        finally:
            adb('shell','settings','put','system','font_scale','1.0')
            adb('shell','wm','size','reset')
            adb('shell','wm','density','reset')
            width, height = original_size
            time.sleep(2)
            home()
    tap('الأذكار',bottom=True)
    top()
    capture(f'android-appearance-{mode}-library.png')
    home()
    tap('أذكار الصباح')
    expect('الفضل والدليل والمعنى', scroll=True)
    capture(f'android-appearance-{mode}-reader.png')
    adb('shell','input','keyevent','KEYCODE_BACK')
    home()
    tap('أذكار المساء', scroll=True)
    expect('1 / 23')
    capture(f'android-content-{mode}-evening-reader.png')
    adb('shell','input','keyevent','KEYCODE_BACK')
    home()
    # Actual offline expanded collection and both newly admitted entries.
    for entry_title, ordinal, short in [('فاطر السماوات والأرض عند المضجع', 17, 'creator'), ('الذكر عند الاستيقاظ من الليل', 18, 'night-waking')]:
        tap('الأذكار', bottom=True)
        top()
        if any(normal('مسح البحث') in normal(n.get('content-desc', '') + n.get('text', '')) for n in snapshot()):
            tap('مسح البحث')
        tap('ابحث عن ذكر')
        for attempt in range(6):
            if any(n.get('class') == 'android.widget.EditText' and n.get('focused') == 'true' for n in snapshot()):
                break
            time.sleep(.3)
        else:
            raise AssertionError('Expanded collection search did not receive focus')
        adb('shell','input','text','Bedtime')
        adb('shell','input','keyevent','KEYCODE_BACK')
        expect('18 ذكر')
        capture(f'android-content-{mode}-sleep-library.png')
        tap(entry_title, scroll=True, node_class='android.view.View')
        expect(f'{ordinal} / 18')
        capture(f'android-content-{mode}-{short}.png')
        tap('الفضل والدليل والمعنى', scroll=True)
        expect('المعنى')
        tap('المعنى', scroll=True, prefix=True)
        capture(f'android-content-{mode}-{short}-evidence.png')
        # Generate the real share image, then cancel the OS sheet without sending.
        top()
        tap('مشاركة بطاقة')
        time.sleep(2)
        activity = adb('shell','dumpsys','activity','activities')
        assert 'ChooserActivity' in activity or 'IntentResolver' in activity, 'Native share sheet not opened'
        capture(f'android-content-{mode}-{short}-share.png')
        adb('shell','input','keyevent','KEYCODE_BACK')
        adb('shell','input','keyevent','KEYCODE_BACK')
        home()
    checks.append(mode+': expanded 18-entry sleep library, both alternative readers/evidence and real share sheets')
    # Filter by an observed source number, then open the first (morning) result.
    for source_number, title, grade, ordinal, short in [
        ('5090', 'العافية في البدن والسمع والبصر', 'حسن الإسناد', 10, 'hasan'),
        ('5069', 'أشهدك وأشهد حملة عرشك', 'ضعيف عند الألباني', 8, 'daif'),
        ('5081', 'حسبي الله لا إله إلا هو', 'الآية قرآنية ثابتة', 12, 'quran-disputed'),
    ]:
        tap('الأذكار', bottom=True)
        top()
        if any(normal('مسح البحث') in normal(n.get('content-desc', '') + n.get('text', '')) for n in snapshot()):
            tap('مسح البحث')
        tap('ابحث عن ذكر')
        adb('shell','input','text',source_number)
        adb('shell','input','keyevent','KEYCODE_BACK')
        expect('2 ذكر')
        tap(title, scroll=True, node_class='android.view.View')
        capture(f'android-reference-{mode}-{short}.png')
        expect(f'{ordinal} / 25')
        expect('تنبيه مهم:')
        expect(grade)
        nodes = snapshot()
        share = [n for n in nodes if normal('مشاركة بطاقة') in normal(n.get('content-desc','') + n.get('text',''))]
        assert share and all(n.get('enabled') == 'false' for n in share), 'Reference share action must be disabled'
        # Read the entire scroll surface, including the controls at its foot.
        for attempt in range(30):
            nodes = snapshot()
            text = ' '.join(n.get('text','') + ' ' + n.get('content-desc','') for n in nodes)
            assert normal('اضغط للعد') not in normal(text), 'Reference counter exposed'
            assert normal('تراجع عن ضغطة') not in normal(text), 'Reference undo exposed'
            if any(normal('التالي') in normal(n.get('content-desc','') + n.get('text','')) and
                   int(re.findall(r'-?\d+', n.get('bounds','[0,0][0,0]'))[1]) > 0 for n in nodes):
                break
            scroll_content(nodes)
        else: raise AssertionError('Reference navigation not reachable')
        capture(f'android-reference-{mode}-{short}-controls.png')
        top()
        adb('shell','settings','put','system','font_scale','2.0')
        time.sleep(2)
        expect('تنبيه مهم:')
        capture(f'android-reference-{mode}-{short}-text200.png')
        scroll_content(snapshot())
        capture(f'android-reference-{mode}-{short}-text200-continuation.png')
        print('PASS: native reference', mode, short, 'normal and 200% text; sharing and devotional controls disabled', flush=True)
        adb('shell','settings','put','system','font_scale','1.0')
        time.sleep(1)
        adb('shell','input','keyevent','KEYCODE_BACK')
        home()
    print('PASS: native reference warnings, disabled controls and 200% text', mode, flush=True)
    checks.append(mode+': Hasan, Daif and Quran/sevenfold distinction; 200% warnings; disabled share; no counter/undo')

    tap('النوافل',bottom=True)
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
    tap('الإعدادات',bottom=True)
    top()
    expect(label)
    assert worship_preferences() == original_preferences, 'Theme switch altered unrelated local preferences'
    checks.append(mode+': two choices, live switch, six screens, restart persistence; all other preferences unchanged')
    home()
(out/'appearance-interactions.json').write_text(json.dumps({'passed':True,'offline':True,'checks':checks},ensure_ascii=False,indent=2))
print('PASS: both appearances, only two choices, offline captures and restart persistence')


