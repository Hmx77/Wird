"""Keep all prior UI pixels except the two owner-approved Ivory Home cards."""
import json
import math
import os
from pathlib import Path
import shutil
import subprocess

BASE = 'd1b5663ccda092a06f5c87ffc24f9d9311f8c1b0'
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
    assert current == prior, f'{name}: text, counts, colors or layout changed'
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
    return {'changedInsideCards': changed, 'changedOutsideCards': outside,
            'textAndLayoutIdentical': True, 'cardBoundsPixels': bounds}

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
    'passed': True, 'intentionalChanges': ['Ivory Morning and Evening artwork and caption feather only'],
    'comparison': '14 Midnight renders and 12 other Ivory renders exact; Ivory Home pixels exact outside the two category cards',
    'smallScreenVerification': '320dp RTL/LTR at 100%/200%; text geometry and outside-card pixels unchanged',
}
Path('verification/midnight-exact-regression.json').write_text(json.dumps(result, indent=2))
print('PASS: 26 unchanged screen renders; Ivory Home changes confined to Morning/Evening cards with identical text and layout')
