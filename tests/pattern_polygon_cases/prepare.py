#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Render native cases from observed instructions and independent proposals, no Qt."""
import argparse,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent))
from polygon_geometry_oracle import satisfies

PROPERTIES={
 'Desenha um polígono.':'polygon',
 'Desenha um triângulo.':'triangle',
 'Desenha um triângulo retângulo.':'right_triangle',
 'Desenha um triângulo isósceles.':'isosceles_triangle',
 'Desenha um quadrilátero.':'quadrilateral',
 'Desenha um retângulo.':'rectangle',
 'Desenha um quadrado.':'square',
 'Desenha um paralelogramo que não seja um retângulo.':'nonrectangular_parallelogram',
 'Desenha um losango que não seja um quadrado.':'nonsquare_rhombus',
}
def render(proposals,inventory):
 if proposals['inventory_sha256']!=inventory['inventory_sha256']:raise ValueError('Different observed inventory identity')
 instructions=inventory['instructions'];questions=proposals['questions']
 if len(instructions)!=9 or len(set(instructions))!=9 or set(instructions)!=set(questions):raise ValueError('Expected the nine observed instructions')
 records=[]
 for text in instructions:
  row=questions[text];vertices=row['vertices']
  if text not in PROPERTIES or row['property']!=PROPERTIES[text]:raise ValueError('Candidate class differs from visible instruction')
  if any(len(p)!=2 or any(type(v) is not int or not 1<=v<=8 for v in p) for p in vertices):raise ValueError('Candidate outside interior grid')
  try:valid=satisfies(vertices,row['property'])
  except ValueError:valid=False
  if not valid:raise ValueError('Independent geometry rejects candidate')
  records.append({'instruction':text,'property':row['property'],'vertices':vertices})
 common=(HERE/'common.fragment').read_text();result={}
 for name in ['pilot','tutorial-nine','controls-free']:
  text=(HERE/(name+'.template')).read_text().replace('__COMMON__',common).replace('__PROPOSALS__',json.dumps(records,ensure_ascii=False,separators=(',',':')))
  result[name+'.qml']=text
 return result

def main():
 if not __debug__:raise SystemExit('Polygon case generation rejects Python -O')
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--proposals',type=Path,default=HERE/'proposals.json');parser.add_argument('--inventory',type=Path,default=HERE/'observed-instructions.json');parser.add_argument('--output',type=Path,required=True);args=parser.parse_args()
 if args.output.exists() or args.output.is_symlink():parser.error('New output required')
 cases=render(json.loads(args.proposals.read_text()),json.loads(args.inventory.read_text()));args.output.mkdir(parents=True)
 for name,text in cases.items():(args.output/name).write_text(text)
 print(json.dumps({'prepared':list(cases),'executed':False}))
if __name__=='__main__':main()
