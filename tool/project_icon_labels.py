from pathlib import Path
import re,json
root=Path(__file__).resolve().parents[1]
text=(root/'scratch/reference-react/demo/components/Icon/IconDemo.tsx').read_text(encoding='utf-8')
block=text.split('const ZH_NAMES:')[1].split('};')[0]
names=re.findall(r"\b(\w+): '([^']+)'",block)
target=root/'example/lib/shared/icon_labels.dart'
target.write_text('// Reference display labels, MIT; not runtime component behavior.\nconst iconLabels = <String,String>{\n'+''.join('  '+json.dumps(n[0].lower()+n[1:])+': '+json.dumps(v,ensure_ascii=False)+',\n' for n,v in names)+'};\n',encoding='utf-8')
print(len(names))
