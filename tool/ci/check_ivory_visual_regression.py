"""Render the approved base with the same SDK/fonts; require exact dark PNGs."""
import json
import os
from pathlib import Path
import shutil
import subprocess

BASE = 'e92057931e2be08804c94051899b5e26edecaa53'
paths = ['lib/appearance.dart', 'lib/premium_ui.dart', 'lib/main.dart', 'lib/settings_ui.dart', 'lib/tasbih_ui.dart', 'test/appearance_test.dart']
images = Path('verification/screenshots')
after = Path('verification/ivory-after')
before = Path('verification/ivory-before')
for folder in [after, before]:
    folder.mkdir(parents=True, exist_ok=True)
for image in images.glob('appearance-*'):
    shutil.copyfile(image, after / image.name)
assert len(list(after.glob('appearance-0-*.png'))) == 14
original = {path: Path(path).read_bytes() for path in paths}
try:
    for path in paths:
        Path(path).write_bytes(subprocess.check_output(['git', 'show', f'{BASE}:{path}']))
    subprocess.run(['flutter', 'test', 'test/appearance_test.dart', '--reporter', 'expanded'],
                   env={**os.environ, 'WIRD_REVIEW_IMAGES': '1', 'WIRD_BASELINE_RENDER': '1'}, check=True)
    for image in images.glob('appearance-*'):
        shutil.copyfile(image, before / image.name)
finally:
    for path, data in original.items():
        Path(path).write_bytes(data)
    for image in after.glob('appearance-*'):
        shutil.copyfile(image, images / image.name)
checks = {image.name: image.read_bytes() == (before / image.name).read_bytes()
          for image in after.glob('appearance-*.png')}
assert len(checks) == 28, checks
Path('verification/midnight-exact-regression.json').write_text(json.dumps(
    {'base': BASE, 'darkScreens': checks, 'passed': all(checks.values()),
     'intentionalSettingsChanges': [], 'comparison': 'Approved PR8 UI rendered with the same expanded catalog; count changes are data, not design changes',
     'settingsVerification': 'Full behavioral and 320dp/200% RTL/LTR tests run against current source; before/after images retained.'}, indent=2))
assert all(checks.values()), checks
print('PASS: 28 both-theme renders identical to approved PR8 UI with expanded data; before/after retained')
