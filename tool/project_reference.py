from pathlib import Path
import re,json
root=Path(__file__).resolve().parents[1];ref=root/'scratch/reference-react'
s=(ref/'demo/App.tsx').read_text(encoding='utf-8')
menu=s[s.index('const MENU_ITEMS:'):s.index('// Shared styles')]
groups=[]
for m in re.finditer(r"label: '── (.*?) ──',\s*children: \[([\s\S]*?)\]",menu):
 items=[]
 for item in re.finditer(r"key: '([^']+)', label: '([^']+)'(, isNew: true)?",m[2]):
  items.append(dict(id=item[1],label=item[2],isNew=bool(item[3])))
 groups.append(dict(label=m[1],items=items))
info=(ref/'demo/pageInfo.ts').read_text(encoding='utf-8')
pages={}
for m in re.finditer(r"(?:'([^']+)'|(\w+)):\s*\{\s*title: '([^']*)',\s*desc: '([^']*)'",info):
 pages[m[1]or m[2]]=dict(title=m[3],description=m[4])
out=['// Reference navigation data; MIT notice in assets/licenses/reference-gallery.txt.','class GalleryEntry { const GalleryEntry(this.id,this.label,this.title,this.description,{this.isNew=false}); final String id,label,title,description; final bool isNew; }','const galleryGroups = <String,List<GalleryEntry>>{']
for g in groups:
 out.append(json.dumps(g['label'],ensure_ascii=False)+': [')
 for i in g['items']:
  d=pages.get(i['id'],{}).get('description','')
  out.append('GalleryEntry('+','.join(json.dumps(v,ensure_ascii=False) for v in [i['id'],i['label'],pages.get(i['id'],{}).get('title',i['label']),d])+',isNew:'+str(i['isNew']).lower()+'),')
 out.append('],')
out.append('};')
(root/'example/lib/shared/catalog.dart').write_text('\n'.join(out)+'\n',encoding='utf-8')
inventory=dict(reference_commit='79810934ee9d08c22044d34e06f8bba40391207b',groups=groups,pages=pages)
(root/'docs/reference-page-inventory.json').write_text(json.dumps(inventory,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('Registered',sum(len(g['items']) for g in groups),'reference routes')
