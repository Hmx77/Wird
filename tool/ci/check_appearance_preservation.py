"""Lock original religious content, services, opening, artwork and native code."""
import hashlib
import json
from pathlib import Path
root = Path(__file__).resolve().parents[2]
manifest = json.loads((root / 'docs/appearance-preservation.json').read_text())
for entry in manifest['files']:
    data = (root / entry['path']).read_bytes()
    actual = hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest()
    assert actual == entry['sha'], entry['path']
print('PASS:', len(manifest['files']), 'protected religious/service/native/original-asset files')
