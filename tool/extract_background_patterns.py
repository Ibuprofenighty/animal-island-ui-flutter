"""Project exact wallpaper data from the pinned reference CSS; no runtime CSS."""
from pathlib import Path
import re, urllib.parse, xml.etree.ElementTree as ET
root=Path(__file__).resolve().parents[1]
css=(root/'scratch/reference-react/src/components/Background/background.module.less').read_text(encoding='utf-8')
order=[('cream','default'),('grid','grid'),('darkGreen','dots-dark-green'),('sprinkles','sprinkles'),('sweetCorner','sweet-corner'),('coffeeBreak','coffee-break'),('pink','dots-pink'),('purple','dots-purple'),('blue','dots-blue'),('yellow','dots-yellow'),('orange','dots-orange'),('teal','dots-teal'),('green','dots-green'),('red','dots-red'),('limeGreen','dots-lime-green'),('yellowGreen','dots-yellow-green'),('brown','dots-brown'),('peach','dots-warm-peach-pink'),('gray','dots-gray')]
def rgba(v):
 r,g,b,a=map(float,v)
 return 'Color(0x%02x%02x%02x%02x)'%(round(a*255),int(r),int(g),int(b))
rows=[]
for name,ref in order:
 m=re.search(r'\.bg-'+ref+r'\s*\{(.*?)\}',css,re.S)
 data=m[1] if m else ''
 dots=re.findall(r'rgba\((\d+),\s*(\d+),\s*(\d+),\s*([\d.]+)\)',data)
 if dots:
  base=re.search(r'(#[0-9a-fA-F]{6}|rgb\([\d,\s]+\))\s*;',data)[1]
  if base.startswith('#'): bg='Color(0xff'+base[1:]+')'
  else: bg='Color(0xff%02x%02x%02x)'%tuple(map(int,re.findall(r'\d+',base)))
  colors=[bg,rgba(dots[0]),rgba(dots[1])]
 else: colors=['Color(0xfff7f3df)' if name=='grid' else 'Color(0xfffdf3e3)','Color(0x00000000)','Color(0x00000000)']
 rows.append("  "+name+"('"+ref+"', "+", ".join(colors)+")")
out="// Generated from pinned Background CSS by tool/extract_background_patterns.py.\nimport 'package:flutter/painting.dart';\nenum IslandBackgroundType {\n"+",\n".join(rows)+";\n  const IslandBackgroundType(this.referenceName, this.color, this.largeDot, this.smallDot);\n  final String referenceName;\n  final Color color, largeDot, smallDot;\n}\n"
(root/'lib/src/foundation/background_type.dart').write_text(out,encoding='utf-8')
layers=[]
for i,encoded in enumerate(re.findall(r'data:image/svg\+xml,([^"]+)',css)):
 svg=ET.fromstring(urllib.parse.unquote(encoded)); ns={'s':'http://www.w3.org/2000/svg'}
 shapes=[]
 for g in svg.findall('s:g',ns):
  x,y,angle=map(float,re.findall(r'-?[\d.]+',g.attrib['transform']))
  rect=g.find('s:rect',ns); a=rect.attrib
  shapes.append("(%s,%s,%s,%s,%s,Color(0xff%s))"%(x,y,angle,float(a['width']),float(a['height']),a['fill'][1:]))
 layers.append("  (%s.0,%s.0,%s.0,%s.0,[%s])"%(svg.attrib['width'],svg.attrib['height'],i*45,i*30,','.join(shapes)))
assert len(layers)==3
(root/'lib/src/internal/sprinkle_data.dart').write_text("// Generated reference sprinkle positions; do not randomize.\nimport 'package:flutter/painting.dart';\nconst sprinkleLayers = <(double,double,double,double,List<(double,double,double,double,double,Color)>)>[\n"+",\n".join(layers)+"\n];\n",encoding='utf-8')
print('Projected 19 wallpapers and 18 sprinkle shapes.')
