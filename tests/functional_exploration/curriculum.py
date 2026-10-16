# SPDX-License-Identifier: GPL-3.0-or-later
"""Independent sizes and visible-text meaning; no hidden question indexes."""
import re
COUNTS={'explore_farm_animals':[9],'explore_world_animals':[5,5,5],'explore_world_music':[9],'explore_monuments':[7,11,10,7,10,4,6,6,4]}
AUDIO={'explore_farm_animals','explore_world_music'}
FARM_CUES={'Ovelha':('lã',),'Porco':('lama',),'Coruja':('noite','noturno','nocturno'),'Cão':('lobo',),'Galinha':('crista','ovos'),'Gato':('ratos','roedores','ronron'),'Pato':('nadar','nada','água','membrana'),'Vaca':('leite','paladar','odores','papilas','sabores','20 000','20000'),'Cavalo':('correr','equilíbrio','cascos','relinch')}
def normal(text):return re.sub(r'^(?:a|o|as|os) ','',text.strip().lower()).rstrip(' .')
def text_target(prompt,lessons):
 named=[p for p in lessons if normal(p['title'])==normal(prompt) or normal(p['title'].split(',')[0])==normal(prompt)]
 if len(named)==1:return named[0]
 titles={title for title,cues in FARM_CUES.items() if any(cue in prompt.lower() for cue in cues)}
 if len(titles)!=1:raise ValueError('Visible question has no unique taught meaning: '+prompt)
 matches=[p for p in lessons if p['title'] in titles]
 if len(matches)!=1:raise ValueError('No unique taught animal')
 return matches[0]
