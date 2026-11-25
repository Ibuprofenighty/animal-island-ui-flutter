from pathlib import Path
import re,json
root=Path(__file__).resolve().parents[1]
text=(root/'scratch/reference-react/demo/components/Icon/IconDemo.tsx').read_text(encoding='utf-8')
block=text.split('const ZH_NAMES:')[1].split('};')[0]
names=re.findall(r"\b(\w+): '([^']+)'",block)
glyphs=set(re.findall(r'IslandGlyph\.(\w+):',(root/'lib/src/foundation/icon_names.dart').read_text(encoding='utf-8')))
# The reference page shows `ZH_NAMES[name] ?? name`: a glyph without a label shows its own name,
# and a label whose glyph upstream removed is never looked up, so it is not projected.
stale=sorted(n for n,_ in names if n[0].lower()+n[1:] not in glyphs)
names=[(n,v) for n,v in names if n[0].lower()+n[1:] in glyphs]
labels={n[0].lower()+n[1:] for n,_ in names}
print('labels without a glyph (dropped):',', '.join(stale) or 'none')
print('glyphs without a label (shown by name):',len(glyphs-labels))
target=root/'example/lib/shared/icon_labels.dart'
target.write_text('// Reference display labels, MIT; not runtime component behavior.\nconst iconLabels = <String,String>{\n'+''.join('  '+json.dumps(n[0].lower()+n[1:])+': '+json.dumps(v,ensure_ascii=False)+',\n' for n,v in names)+'};\n',encoding='utf-8',newline='\n')
print(len(names))
