"""Keep all prior UI pixels except the two owner-approved Ivory Home cards."""
import json
import math
import os
from pathlib import Path
import shutil
import subprocess

BASE = '82aa15a8b3bf7c06b32fc2672149136464ae098d'
# Keep the current capture harness for both revisions so it records comparable
# text geometry and raw pixels; only production code changes for the replay.
paths = ['lib/appearance.dart', 'lib/premium_ui.dart', 'lib/main.dart',
         'lib/settings_ui.dart', 'lib/feature_panels.dart', 'lib/tasbih_ui.dart']
images = Path('verification/screenshots')
after = Path('verification/ivory-after')
before = Path('verification/ivory-before')
for folder in [after, before]:
    folder.mkdir(parents=True, exist_ok=True)

def captures(folder):
    return [p for p in folder.iterdir()
            if p.name.startswith(('appearance-', 'ivory-home-', 'ivory-shell-'))]

for image in captures(images):
    shutil.copyfile(image, after / image.name)
assert len(list(after.glob('appearance-0-*.png'))) == 14
original = {path: Path(path).read_bytes() for path in paths}
try:
    for path in paths:
        Path(path).write_bytes(subprocess.check_output(['git', 'show', f'{BASE}:{path}']))
    subprocess.run(['flutter', 'test', 'test/appearance_test.dart', '--reporter', 'expanded'],
                   env={**os.environ, 'WIRD_REVIEW_IMAGES': '1', 'WIRD_BASELINE_RENDER': '1'}, check=True)
    for image in captures(images):
        shutil.copyfile(image, before / image.name)
finally:
    for path, data in original.items():
        Path(path).write_bytes(data)
    for image in captures(after):
        shutil.copyfile(image, images / image.name)

def home_scope(name, must_change=False):
    current = json.loads((after / f'{name}-text.json').read_text())
    prior = json.loads((before / f'{name}-text.json').read_text())
    # Only the two approved caption colors change; content and geometry cannot.
    expected = json.loads(json.dumps(prior))
    for item in expected['text']:
        if item.get('card') in ('home-morning', 'home-evening'):
            item['argb'] = 0xFFFAF6E9
    assert current == expected, f'{name}: unapproved text, count, color or layout change'
    width, height = current['width'], current['height']
    scale = current['pixelRatio']
    bounds = [[math.floor(v * scale) if i < 2 else math.ceil(v * scale)
               for i, v in enumerate(rect)] for rect in current['cards'].values()]
    a = (after / f'{name}.rgba').read_bytes()
    b = (before / f'{name}.rgba').read_bytes()
    assert len(a) == len(b) == width * height * 4
    changed = 0
    outside = 0
    for pixel in range(width * height):
        offset = pixel * 4
        if a[offset:offset + 4] == b[offset:offset + 4]:
            continue
        x, y = pixel % width, pixel // width
        if any(left <= x < right and top <= y < bottom for left, top, right, bottom in bounds):
            changed += 1
        else:
            outside += 1
    assert outside == 0, f'{name}: {outside} changed pixels outside approved cards'
    if must_change:
        assert changed > 1000, f'{name}: approved scenery update did not render'
    lower_cream = []
    if must_change:
        for left, top, right, bottom in bounds:
            start = top + round((bottom - top) * .55)
            pixels = 0
            cream = 0
            for y in range(max(0, start), min(height, bottom - 2)):
                for x in range(max(0, left + 2), min(width, right - 2)):
                    i = (y * width + x) * 4
                    pixels += 1
                    cream += a[i] > 215 and a[i+1] > 210 and a[i+2] > 190
            fraction = cream / pixels
            assert fraction < .28, f'{name}: lower scenery obscured by cream ({fraction:.1%})'
            lower_cream.append(fraction)
    return {'changedInsideCards': changed, 'changedOutsideCards': outside,
            'textContentAndGeometryIdentical': True, 'approvedCaptionColor': '#FAF6E9',
            'lowerSceneCreamFraction': lower_cream, 'cardBoundsPixels': bounds}

checks = {}
scoped = {}
for image in after.glob('appearance-*.png'):
    if image.stem in ('appearance-1-ar-home', 'appearance-1-en-home'):
        scoped[image.stem] = home_scope(image.stem, must_change=True)
    else:
        checks[image.name] = image.read_bytes() == (before / image.name).read_bytes()
assert len(checks) == 26, checks
assert all(checks.values()), checks
for image in after.glob('ivory-home-*.png'):
    scoped[image.stem] = home_scope(image.stem)
# The 320dp/200% shell capture also keeps its full navigation and layout.
shell = 'ivory-shell-320-ar-text200.png'
assert (after / shell).read_bytes() == (before / shell).read_bytes(), shell
result = {
    'base': BASE, 'unchangedScreens': checks, 'scopedIvoryHomes': scoped,
    'passed': True, 'intentionalChanges': ['Ivory Morning/Evening full scenery, cream captions and Morning badge; no wash'],
    'comparison': '14 Midnight renders and 12 other Ivory renders exact; Ivory Home pixels exact outside the two category cards',
    'smallScreenVerification': '320dp RTL/LTR at 100%/200%; text geometry and outside-card pixels unchanged',
}
Path('verification/midnight-exact-regression.json').write_text(json.dumps(result, indent=2))
print('PASS: 26 unchanged renders; only approved cards change, text geometry preserved, no cream lower panels')

