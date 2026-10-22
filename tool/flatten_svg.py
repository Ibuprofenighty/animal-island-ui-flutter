"""Expand local SVG use references without altering geometry or renderer limits."""
import copy
import math
import xml.etree.ElementTree as ET
SVG='http://www.w3.org/2000/svg'
XLINK='http://www.w3.org/1999/xlink'
ET.register_namespace('',SVG)
ET.register_namespace('xlink',XLINK)

def _expand_circle_tiles(document):
 """Materialize the pinned finite circle grids; no runtime shader is needed."""
 tag=lambda name:'{'+SVG+'}'+name
 for pattern in list(document.iter(tag('pattern'))):
  if set(pattern.attrib)!={'id','width','height','patternUnits'} or pattern.get('patternUnits')!='userSpaceOnUse':
   raise ValueError('Unsupported pattern geometry')
  if len(pattern)!=1 or pattern[0].tag!=tag('circle'):
   raise ValueError('Only the pinned circle tile is supported')
  circle=pattern[0]
  if set(circle.attrib)!={'cx','cy','r','fill','opacity'}:
   raise ValueError('Unexpected circle tile styling')
  width,height=map(float,[pattern.get('width'),pattern.get('height')])
  cx,cy,radius=map(float,[circle.get('cx'),circle.get('cy'),circle.get('r')])
  if not all(math.isfinite(v) and v>0 for v in [width,height,radius]) or not(radius<=cx<=width-radius and radius<=cy<=height-radius):
   raise ValueError('Circle must fit its finite tile')
  view=list(map(float,document.get('viewBox','').split()))
  if len(view)!=4 or view[:2]!=[0,0] or not all(math.isfinite(v) and v>0 for v in view[2:]):
   raise ValueError('A finite zero-origin scene viewBox is required')
  w,h=view[2:];key=pattern.get('id');bounds=key+'-tile-bounds'
  if any(n.get('id')==bounds for n in document.iter()):raise ValueError('Duplicate tile clip identity')
  uses=[n for n in document.iter() if n.get('fill')=='url(#'+key+')']
  if len(uses)!=1 or uses[0].tag!=tag('path') or set(uses[0].attrib)!={'fill','d'} or uses[0].get('d')!=f'M0 0h{w:g}v{h:g}H0z':
   raise ValueError('Circle tiles require the pinned full-viewBox fill')
  clip=ET.Element(tag('clipPath'),{'id':bounds})
  ET.SubElement(clip,tag('rect'),{'width':f'{w:g}','height':f'{h:g}'})
  group=ET.Element(tag('g'),{'clip-path':'url(#'+bounds+')'})
  columns,rows=math.ceil(w/width),math.ceil(h/height)
  if columns*rows>200000:raise ValueError('Expanded SVG node budget exceeded')
  for y in range(rows):
   for x in range(columns):
    attrs=dict(circle.attrib);attrs.update(cx=f'{cx+x*width:g}',cy=f'{cy+y*height:g}')
    ET.SubElement(group,tag('circle'),attrs)
  for parent in document.iter():
   for index,child in enumerate(list(parent)):
    if child is pattern:parent.remove(child);parent.insert(index,clip)
    elif child is uses[0]:parent.remove(child);parent.insert(index,group)

def flatten(source):
 document=ET.fromstring(source)
 ids={node.attrib['id']:node for node in document.iter() if 'id' in node.attrib}
 total=0
 def expand(node, chain=()):
  nonlocal total
  total+=1
  if total>200000: raise ValueError('Expanded SVG node budget exceeded')
  if node.tag=='{'+SVG+'}use':
   href=node.attrib.get('href') or node.attrib.get('{'+XLINK+'}href')
   if not href or not href.startswith('#') or href[1:] not in ids: raise ValueError('Unresolved/nonlocal SVG use')
   key=href[1:]
   if key in chain: raise ValueError('Cyclic SVG reference')
   attrs={k:v for k,v in node.attrib.items() if k not in ('href','{'+XLINK+'}href','x','y','id')}
   group=ET.Element('{'+SVG+'}g',attrs)
   x,y=node.attrib.get('x','0'),node.attrib.get('y','0')
   if x!='0' or y!='0':
    nested=ET.SubElement(group,'{'+SVG+'}g',{'transform':f'translate({x} {y})'})
   else: nested=group
   target=copy.deepcopy(ids[key]);target.attrib.pop('id',None)
   nested.append(expand(target,chain+(key,)))
   return group
  result=ET.Element(node.tag,dict(node.attrib));result.text=node.text;result.tail=node.tail
  for child in node: result.append(expand(child,chain))
  return result
 result=expand(document)
 _expand_circle_tiles(result)
 assert not any(n.tag=='{'+SVG+'}use' for n in result.iter())
 return ET.tostring(result,encoding='utf-8',xml_declaration=True)


if __name__ == '__main__':
 from pathlib import Path
 import argparse
 parser=argparse.ArgumentParser(description=__doc__)
 parser.add_argument('source',type=Path)
 parser.add_argument('output',type=Path)
 args=parser.parse_args()
 if args.source.resolve()==args.output.resolve():parser.error('Use a separate output; keep the pinned input unchanged.')
 args.output.write_bytes(flatten(args.source.read_bytes()))
