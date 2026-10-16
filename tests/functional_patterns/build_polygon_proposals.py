#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Construct independent examples for the nine observed public instructions."""
import argparse,hashlib,json,sys
from fractions import Fraction
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from polygon_geometry_oracle import propose,classify,satisfies
PROPERTIES={'Desenha um polígono.':'polygon','Desenha um triângulo.':'triangle','Desenha um triângulo retângulo.':'right_triangle','Desenha um triângulo isósceles.':'isosceles_triangle','Desenha um quadrilátero.':'quadrilateral','Desenha um retângulo.':'rectangle','Desenha um quadrado.':'square','Desenha um paralelogramo que não seja um retângulo.':'nonrectangular_parallelogram','Desenha um losango que não seja um quadrado.':'nonsquare_rhombus'}
def encode_fraction(value):
 if isinstance(value,Fraction):return {'numerator':value.numerator,'denominator':value.denominator}
 raise TypeError(f'Unsupported JSON value: {type(value).__name__}')
def main():
 p=argparse.ArgumentParser();p.add_argument('--inventory',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
 if a.output.exists() or a.output.is_symlink():p.error('Output must be new')
 boards=json.loads(a.inventory.read_text())['case_result']['boards'];records={}
 for b in boards:
  text=b['instruction'];vertices=propose(text);property_name=PROPERTIES[text]
  if not satisfies(vertices,property_name):raise ValueError('Candidate fails independent geometry')
  records[text]={'vertices':vertices,'property':property_name,'geometry':classify(vertices)}
 result={'scope':'Independent integer examples, not authored positions or unique solutions','inventory_sha256':hashlib.sha256(a.inventory.read_bytes()).hexdigest(),'questions':records}
 with a.output.open('x') as f:f.write(json.dumps(result,ensure_ascii=False,indent=2,default=encode_fraction)+'\n')
 print(json.dumps({'instructions':len(records),'scope':result['scope']}))
if __name__=='__main__':main()
