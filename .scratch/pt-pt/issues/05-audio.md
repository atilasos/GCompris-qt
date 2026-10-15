# Verificar cobertura e pronúncia do áudio PT-PT

Status: ready-for-agent
Progress: claimed
Type: task
Blocked by: 01

## Aceitação

- Inspecionar os pacotes RCC `pt` e listar gravações usadas por cada atividade.
- Cruzar os ficheiros efetivamente distribuídos com as referências nos exercícios.
- Rever `po/pt/gcompris_voices.po`; o catálogo textual não prova cobertura sonora.
- Aproveitar gravações corretas. Preparar amostras de síntese PT-PT para aprovação
  antes de produzir novas gravações em escala.
- Validar especificamente sons e nomes das letras, números e palavras.
- Registar origem e licença de novos recursos e verificar reprodução offline nos
  formatos usados pelas compilações Linux e Windows.


## Progresso de implementação

Inventário de bytes RCC e descodificação dos 1578 ficheiros concluídos em Linux.
Os guiões PO foram corrigidos. Relatório e procedimento reproduzível em
`../audio/review.md` e `../audio/coverage.json`.

A aceitação continua pendente: gravações em falta, aprovação das amostras de voz,
validação pedagógica dos sons/letras, audição nas atividades e reprodução no
Windows 10 x64. A inspeção do catálogo não substitui gravações. Não marcar como
resolvida enquanto estes critérios permanecerem pendentes.
