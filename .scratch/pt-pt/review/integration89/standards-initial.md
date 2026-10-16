# Standards — tarefa89

Base: `faa44382bf0d3f6d03ce8c0c24f51ed89b076400`.
Head: `e40f2147084129add29f7d16d2ffb0cf0e5e33f7`.
Intervalo: `git diff faa44382b...e40f21470`; commits:
`e40f21470,83431932c,01c984690,afc7ac11a,416ddcc9d,728cfdc72,1c5f33e24,b9658f7d4,9c1fa4b62,4a4e636b6,7992a59d8`.

Li a skill code-review integralmente, incluindo as12 heurísticas Fowler;
AGENTS.md, HACKING, README.md e docs/agents/{domain,issue-tracker,triage-labels}.
Não existem GLOSSARY.md, ADRs, CONTRIBUTING ou CODING_STANDARDS locais encontrados.
Normas documentadas prevalecem; regras já impostas por ferramentas foram excluídas.
A revisão é exclusivamente Standards, por atribuição, sem delegação adicional.

**P3 — possível Duplicated Code, julgamento de manutenção, não violação dura.**
O mesmo pipeline de compilação do exportador RCC foi acrescentado três vezes:
`tests/functional_creation/run.py:25`, `capture_resources.py:16` e `seal.py:47`.
Hunk comum: `flags=subprocess.check_output(['pkg-config','--cflags','--libs','Qt6Core'],text=True).split();subprocess.run(['g++','-std=c++17','-fPIC',str(cpp),'-o',str(...),*flags],check=True)`;
os três também executam o exportador e interpretam JSON. Uma mudança nas flags
ou no contrato do exportador exige manutenção coordenada em três ferramentas.
A baseline Duplicated Code recomenda extrair a forma partilhada. Um helper
pequeno de compilação/exportação usado pelas ferramentas futuras eliminaria esse
ponto de divergência, mantendo destinos e fontes explícitos. Não reescrever
capturadores históricos nem cápsulas para o fazer. Não encontrei norma local
que exija estas três cópias operacionais; os casos QML expandidos arquivados,
por outro lado, têm propósito de identidade histórica e não são este achado.

**Violações duras: zero.** Não encontrei outros smells acionáveis entre nomes,
Feature Envy, Data Clumps, Primitive Obsession, Repeated Switches, Shotgun Surgery,
Divergent Change, Speculative Generality, Message Chains, Middle Man ou Refused
Bequest. O ramo é um fork local; a proibição README de MR com código AI para o
upstream não foi contrariada por esta entrega/merge local autorizado.

O auditor mantém âncoras literais, recibos antigos e recusa explícita de -O;
limites de cobertura e retornos não zero permanecem documentados. Não refaço
aceitação Spec, Windows ou estabilidade83. Sem Qt, alteração de ficheiros do
projeto, build ou push nesta revisão.

Total:1 achado Standards, P3 de manutenção;0 violações documentadas duras.
