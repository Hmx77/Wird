"""Exact scope guard: authorized standalone extraction, no approved-screen edits."""
import hashlib,json
from pathlib import Path
root=Path(__file__).resolve().parents[2]
m=json.loads((root/'docs/tasbih-preservation.json').read_text())
e=json.loads((root/'docs/tasbih-extraction.json').read_text())
for f in m['files']+m['normalized']:
    data=(root/f['path']).read_bytes()
    if f['path']==e['path']:
        assert data.count(e['after'].encode())==1
        data=data.replace(e['after'].encode(),e['before'].encode(),1)
    if f['path']=='lib/main.dart':
        part=b"part 'tasbih_ui.dart';\n"
        assert data.count(part)==1
        data=data.replace(part,b'',1)
    assert hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()==f['sha'],f['path']
print('PASS: exact standalone extraction; all',len(m['files']),'protected source/native/assets unchanged')
