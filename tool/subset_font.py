"""Rebuild the Gallery-only font from the upstream Noto Sans SC variable font.
Requires fonttools==4.60.1. Source font path is explicit; never fetches automatically.
"""
from pathlib import Path
import hashlib, json, sys
from fontTools import subset
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont
import copy
root=Path(__file__).resolve().parents[1]
source=Path(sys.argv[1])
text="".join(p.read_text(encoding="utf-8") for folder in (root/"example/lib",root/"lib") for p in folder.rglob("*.dart"))
# Pin reference-copy coverage before adding future Gallery pages.
for folder in (root/"scratch/reference-react/src",root/"scratch/reference-react/demo"):
    if not folder.is_dir(): raise SystemExit(f"Missing pinned reference: {folder}")
    text+="".join(p.read_text(encoding="utf-8") for p in sorted(folder.rglob("*")) if p.suffix in (".ts",".tsx"))
text+="".join(chr(c) for c in range(32,127))
text+="".join(chr(c) for c in range(0x2000,0x2070))
# Include all common GB2312 ideographs so visitor names aren't limited to demo copy.
for lead in range(0xB0,0xF8):
    for trail in range(0xA1,0xFF):
        try: text+=bytes([lead,trail]).decode("gb2312")
        except UnicodeDecodeError: pass
font=TTFont(source)
options=subset.Options()
options.name_IDs=["*"];options.name_languages=["*"];options.name_legacy=True
sub=subset.Subsetter(options=options);sub.populate(text=text);sub.subset(font)
# Reference outlines are400/500/700. Register the bold outlines at900 so
# Flutter600..900 requests select them without synthetic emboldening.
# This is one Gallery font family with three faces, not a runtime text adapter.
outputs=[]
for weight,outline_weight,style in [(400,400,"Regular"),(500,500,"Medium"),(900,700,"Black")]:
    instance=instantiateVariableFont(copy.deepcopy(font),{"wght":outline_weight},inplace=True)
    instance.recalcTimestamp=False
    instance["OS/2"].usWeightClass=weight
    if weight != outline_weight and "STAT" in instance: del instance["STAT"]
    for record in instance["name"].names:
        if record.nameID in (1,2,4,6,16,17):
            value={1:"Island Gallery Sans",2:style,4:f"Island Gallery Sans {style}",6:f"IslandGallerySans-{weight}",16:"Island Gallery Sans",17:style}[record.nameID]
            record.string=value.encode(record.getEncoding())
    instance["OS/2"].fsSelection &= ~((1<<5)|(1<<6))
    if weight>=700: instance["OS/2"].fsSelection |= 1<<5
    if weight==400: instance["OS/2"].fsSelection |= 1<<6
    instance["head"].macStyle=(instance["head"].macStyle & ~1) | (1 if weight>=700 else 0)
    destination=root/f"example/assets/fonts/IslandGallerySans-{weight}.ttf"
    instance.save(destination)
    outputs.append({"path":destination.name,"weight":weight,"outline_weight":outline_weight,"sha256":hashlib.sha256(destination.read_bytes()).hexdigest(),"bytes":destination.stat().st_size})
manifest={"source":"https://github.com/google/fonts/tree/main/ofl/notosanssc","upstream_sha256":hashlib.sha256(source.read_bytes()).hexdigest(),
          "instances":outputs,"license":"SIL OFL 1.1; retained in OFL.txt","family":"Island Gallery Sans",
          "coverage":"Gallery and pinned reference source text, ASCII, general punctuation and GB2312 ideographs; not all Unicode",
          "transformation":"Subset reference outlines400/500/700; register bold as900 with matching names and no stale STAT weight so Flutter600..900 renders700 without synthesis. Preserve original coverage.",
          "tool":"fonttools 4.60.1"}
(root/"example/assets/fonts/provenance.json").write_text(json.dumps(manifest,indent=2)+"\n",encoding="utf-8")
print(json.dumps(manifest))
