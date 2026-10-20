"""Lock approved screens, religious catalog, services and original assets to base."""
import hashlib,json
from pathlib import Path
root=Path(__file__).resolve().parents[2]
manifest=json.loads((root/'docs/reader-preservation.json').read_text())
for f in manifest['files']:
    data=(root/f['path']).read_bytes()
    extraction=json.loads((root/'docs/tasbih-extraction.json').read_text())
    if f['path']==extraction['path']:
        assert data.count(extraction['after'].encode())==1,'Unexpected Tasbih route wrapper'
        data=data.replace(extraction['after'].encode(),extraction['before'].encode(),1)
    route=manifest['homeLibraryRoute']
    if f['path']==route['path']:
        assert data.count(route['after'].encode())==1,'Unexpected Library route wrapper'
        data=data.replace(route['after'].encode(),route['before'].encode(),1)
    assert hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()==f['sha'],f['path']
print('PASS:',len(manifest['files']),'approved screen rendering, religious files, services and original assets preserved; exact Library route color exception checked')
