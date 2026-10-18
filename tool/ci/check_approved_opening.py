"""Keep the owner-approved splash, native launch and launcher assets immutable."""
import hashlib
import json
import sys
import subprocess
from pathlib import Path
root = Path(__file__).resolve().parents[2]
lock = json.loads((root / 'docs/approved-opening-lock.json').read_text())
restore = '--restore-assets' in sys.argv
files = {name: sha for name, sha in lock['gitBlobSha1'].items()
         if not restore or name.endswith('.png')}
if restore:
    # Branding tests may render temporary native candidates. Ship the approved
    # committed images, not regenerated candidates from a different runner.
    subprocess.run(['git', 'restore', '--worktree', '--', *files], cwd=root, check=True)
for name, expected in files.items():
    data = (root / name).read_bytes()
    actual = hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest()
    assert actual == expected, f'Approved opening/launcher file changed: {name}'
print(f"PASS: {len(files)} approved splash/native-launch/launcher files unchanged")
