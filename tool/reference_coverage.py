"""Fail closed when a reference route lacks an executable Gallery story."""
from pathlib import Path
import json,re,sys
root=Path(__file__).resolve().parents[1]
inventory=json.loads((root/'docs/reference-page-inventory.json').read_text(encoding='utf-8'))
expected=[i['id'] for g in inventory['groups'] for i in g['items']]
registry=(root/'example/lib/pages/stories/registry.dart').read_text(encoding='utf-8')
implemented=set(re.findall(r"'([^']+)'\s*:\s*\(_\)",registry))
missing=[i for i in expected if i not in implemented]
result={'component_count':40,'guide_count':1,'registered_stories':len(implemented),'missing_routes':missing,
 'visual_acceptance':'NOT_ACCEPTED','status':'INCOMPLETE' if missing else 'READY_FOR_VISUAL_REVIEW'}
print(json.dumps(result,ensure_ascii=False,indent=2))
sys.exit(1 if missing else 0)
