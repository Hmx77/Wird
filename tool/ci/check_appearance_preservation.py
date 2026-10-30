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

# Pin the original 51 literal payloads independently of the catalog wiring.
source = (root / 'lib/content.dart').read_text()
original = source.split('const contentCatalog = <DhikrEntry>[', 1)[1].split('\n];', 1)[0]
assert hashlib.sha256(original.encode()).hexdigest() == manifest['acceptedCatalog']['literalSHA256'], 'Original 51 catalog payloads changed'
audit = json.loads((root / manifest['acceptedCatalog']['audit']).read_text())
assert len(audit['entries']) == manifest['acceptedCatalog']['entries'] == 51
print('PASS: immutable original 51-entry catalog; reference-only file independently locked')
