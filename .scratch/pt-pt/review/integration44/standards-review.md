# Standards — tarefa 44

Base: `34ebad9be17ffa1b9e73024b28b40b7b801fb348`  
Head: `daf3ae13f2c23597945a37c99407a3b914305e1a`

Não identifiquei violações acionáveis dos padrões documentados nem dos smells Fowler no diff. Consultei AGENTS.md, HACKING, README.md e docs/agents/{domain,issue-tracker,triage-labels}. Não existem GLOSSARY.md, docs/adr/, CONTRIBUTING ou CODING_STANDARDS aplicáveis. O aviso do README sobre contribuições AI ao projeto original é respeitado: este trabalho permanece no fork e numa branch própria. Não executei Qt, builds nem alterações no repositório.

Observação de correção para o coordenador (fora da contagem Standards): **P2 — validar a proveniência antes de publicar**, em `tools/pt-pt-audio/complete_voices.py:163–173`. Os novos `provenance_files` exigem `pt-pt-additions-NOTICE.md`, mas NOTICE permanece opcional nas linhas166–168. Numa origem sem NOTICE e destino limpo, o `stat()` da linha171 falha apenas depois de RCC e Contents já terem sido substituídos nas linhas147–148. A execução termina com erro deixando recursos novos publicados e completion.json anterior ou ausente. Preparar e validar toda a proveniência no diretório temporário antes de substituir os recursos; acrescentar um caso NOTICE ausente que comprove a preservação dos bytes publicados. Esta é uma conclusão de fluxo estático, não uma reprodução executada nem uma violação de regra documental.

Total Standards: **0**. Observação adicional de correção: **1 P2**, enviada ao coordenador para tratamento no eixo adequado.
