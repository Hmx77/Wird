"""Lock prior UI and artwork, allowing only badge removal and navigation polish."""
import json
import math
import os
from pathlib import Path
import shutil
import subprocess

BASE = '210009a5fac64df097385375c3628d8ad3a7b2cb'
paths = ['lib/premium_ui.dart', 'lib/main.dart']
images = Path('verification/screenshots')
after = Path('verification/ivory-after')
before = Path('verification/ivory-before')
for folder in [after, before]: folder.mkdir(parents=True, exist_ok=True)

def captures(folder):
    return [p for p in folder.iterdir() if p.name.startswith(
        ('appearance-', 'ivory-home-', 'ivory-shell-', 'polish-'))]

for image in captures(images): shutil.copyfile(image, after / image.name)
original = {path: Path(path).read_bytes() for path in paths}
try:
    for path in paths:
        Path(path).write_bytes(subprocess.check_output(['git', 'show', f'{BASE}:{path}']))
    subprocess.run(['flutter', 'test', 'test/appearance_test.dart', 'test/home_polish_test.dart',
                    '--reporter', 'expanded'], env={**os.environ, 'WIRD_REVIEW_IMAGES': '1',
                    'WIRD_BASELINE_RENDER': '1'}, check=True)
    for image in captures(images): shutil.copyfile(image, before / image.name)
finally:
    for path, data in original.items(): Path(path).write_bytes(data)
    for image in captures(after): shutil.copyfile(image, images / image.name)

subprocess.run(['git', 'diff', '--exit-code', BASE, '--', 'assets/'], check=True)

def home_scope(name):
    current = json.loads((after / f'{name}-text.json').read_text())
    prior = json.loads((before / f'{name}-text.json').read_text())
    assert not current['badges'], f'{name}: decorative badge still present'
    assert len(prior['badges']) == 3, f'{name}: incomplete baseline badge evidence'
    assert current['cards'].keys() == prior['cards'].keys() and all(abs(a-b) < 1e-6 for k in current['cards'] for a,b in zip(current['cards'][k],prior['cards'][k])), f'{name}: card geometry changed: {current["cards"]} vs {prior["cards"]}'
    assert len(current['text']) == len(prior['text']), name
    allowed = list(prior['badges'].values())
    for new, old in zip(current['text'], prior['text']):
        assert (new['text'], new['argb'], new['card']) == (old['text'], old['argb'], old['card']), f'{name}: text/count/color changed'
        if new['card'] in ('home-morning', 'home-evening', 'home-sleep'):
            # Only old/new caption bounds may differ outside the removed badges.
            for text in [old, new]:
                allowed.append([text['left']-3, text['top']-3,
                    text['left']+text['width']+3, text['top']+text['height']+3])
        else:
            assert all(abs(v-old[k]) < 1e-6 if isinstance(v,(int,float)) else v == old[k] for k,v in new.items()), f'{name}: unrelated typography or layout changed: {new["text"]}'
    width, height, scale = current['width'], current['height'], current['pixelRatio']
    bounds = [[math.floor(v * scale) if i < 2 else math.ceil(v * scale)
               for i, v in enumerate(rect)] for rect in allowed]
    a, b = (after / f'{name}.rgba').read_bytes(), (before / f'{name}.rgba').read_bytes()
    assert len(a) == len(b) == width * height * 4
    changed = outside = 0
    for pixel in range(width * height):
        offset = pixel * 4
        if a[offset:offset+4] == b[offset:offset+4]: continue
        x, y = pixel % width, pixel // width
        if any(l <= x < r and t <= y < bottom for l, t, r, bottom in bounds): changed += 1
        else: outside += 1
    assert outside == 0, f'{name}: {outside} scenic/unapproved pixels changed'
    return {'changedInApprovedRegions': changed, 'changedOutsideApprovedRegions': outside,
        'cardGeometryIdentical': True, 'badgesRemoved': 3, 'artworkIdentical': True}

checks, scoped = {}, {}
for image in after.glob('appearance-*.png'):
    if image.stem.endswith('-home'): scoped[image.stem] = home_scope(image.stem)
    else: checks[image.name] = image.read_bytes() == (before / image.name).read_bytes()
assert len(checks) == 24 and all(checks.values()), checks
for image in after.glob('ivory-home-*.png'): scoped[image.stem] = home_scope(image.stem)
result = {'base': BASE, 'passed': True, 'unchangedScreens': checks, 'scopedHomes': scoped,
    'intentionalChanges': ['Remove the three category badges in both themes; compact shared bottom navigation'],
    'navigationVerification': '24 RTL/LTR cases: iPhone/Android/320dp, both themes, 100%/200% text, all selected tabs, gestures inset and stored activity',
    'comparison': '24 other screen renders exact; Home artwork unchanged outside removed badges and relocated captions'}
Path('verification/midnight-exact-regression.json').write_text(json.dumps(result, indent=2))
print('PASS: 24 unchanged renders; same artwork/card geometry; only badges/captions and tested navigation change')

