"""Lock approved screens, religious catalog, services and original assets to base."""
import hashlib,json
from pathlib import Path
root=Path(__file__).resolve().parents[2]
manifest=json.loads((root/'docs/reader-preservation.json').read_text())
for f in manifest['files']:
    data=(root/f['path']).read_bytes()
    assert hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()==f['sha'],f['path']
print('PASS:',len(manifest['files']),'approved screens, religious files, services and original assets unchanged')
