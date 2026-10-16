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

As amostras de voz e as 32 gravações completas foram aprovadas pelo professor.
A aceitação continua pendente para audição nas atividades, validação pedagógica
global dos sons/letras e reprodução no Windows 10 x64. A inspeção do catálogo não substitui gravações. Não marcar como
resolvida enquanto estes critérios permanecerem pendentes.


### Recursos em falta produzidos após aprovação

O professor aprovou as amostras e os nomes explícitos dos caracteres acentuados.
Foram gerados apenas os 32 ficheiros em falta, com o modelo e a configuração
originais. O manifesto versionado em `resources/pt-pt-voices/` regista textos,
proveniência, hashes e parâmetros. Não foram substituídos fonemas nem gravações.

O pacote completo produzido pela tarefa `getAssets` num build privado contém
1610 recursos: os 1578 originais, preservados byte a byte, mais os 32 novos.
A auditoria real do RCC não encontra lacunas nos seis grupos verificados e todos
os 1610 recursos passaram a descodificação Ogg em Linux. Foram alinhados dez
rótulos geográficos do catálogo com os nomes portugueses gravados.

Procedimento e evidência em `../audio/completion-review.md`. A integração Windows
usa o mesmo combinador depois de obter os recursos originais. A tarefa continua
aberta para verificação nas atividades e reprodução em Windows. O professor
aprovou a pronúncia e os textos das 32 gravações completas; essa aprovação
não é certificação dos 203 jogos.

### Aprovação das 32 gravações completas

O professor ouviu o ZIP da tarefa26 e confirmou «Ouvi as 32 e aprovo.»
Os textos e SHA256 foram comparados com o ZIP ouvido e os OGG atuais.
O registo em resources/pt-pt-voices/manifest.json e na tarefa35 conserva
a aprovação por ficheiro; não há nova geração nem alteração dos bytes sonoros.
