# Compasso: verificação parcial em Linux

Resultado global: pending.

Ambiente: Ubuntu 26.04, Qt 6.10.2, aplicação 26.2, branch `work/pt-pt` com alterações
locais. Idioma `pt_PT.UTF-8`, recursos de voz `pt`, áudio OGG. Renderização software.

## Verificações realizadas

- A atividade bloqueava no carregamento por erro de sintaxe no seletor de cores.
  Reprodução e correção documentadas na tarefa 09.
- Após a correção e a recompilação, o teste de arranque executou durante seis
  segundos sem os erros QML anteriores.
- Numa janela X11 real, a atividade abriu e respondeu à tecla P, mostrando o painel
  da caneta. A captura contém os controlos Cor, Opacidade e Espessura da caneta.
- Os logs confirmaram o carregamento do pacote de vozes PT a partir dos recursos
  locais. A execução foi feita sem som; a qualidade sonora não foi avaliada.

## Evidências

- `build/pt-pt/smoke-before/compass.log`.
- `build/pt-pt/smoke-after/compass.log`.
- `build/pt-pt/compass-before.png`.
- `build/pt-pt/compass-pt-pt.png`.
- `build/pt-pt/compass-fixed.log`.

## Pendente

Testar desenho e edição, os modos e níveis, os restantes controlos, o áudio e a
execução sem rede num perfil novo. Rever linguagem com o professor e executar em
Windows 10, incluindo na escola.
