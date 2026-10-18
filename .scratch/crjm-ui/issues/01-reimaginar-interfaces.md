# 01: Reimaginar as interfaces nativas dos oito jogos

Status: ready-for-agent
Type: task
Progress: resolved
Blocked by: None (can start immediately)

## Scope

Corrigir as interfaces de Dominório, Gatos & Cães, Faísca, Quelhas, Atari Go,
Produto, Y e Nex para jogar no contexto do GCompris. O utilizador forneceu
capturas em que o tabuleiro é minúsculo ou desaparece entre controlos enormes.
Não seguir o desenho do site. Priorizar o tabuleiro, a jogada e instruções curtas.

## Acceptance criteria

- [x] Área de jogo ampla e utilizável em computador, tablet e retrato.
- [x] Controlos secundários não consomem o espaço do tabuleiro.
- [x] Escala do ecrã e tamanho de texto não provocam colapso do layout.
- [x] Seleção e confirmação de ações compostas são claras.
- [x] Todos os oito jogos são revistos visualmente e exercitados na aplicação Qt.
- [x] Build local atualizada, com regressão das regras e dos modos existentes.

## Comments

A aceitação anterior de dimensões de janela não reproduzia a escala do monitor.
A correção inclui uma reprodução com dimensão real do ecrã virtual.


## Answer

Oito interfaces redesenhadas com prioridade ao tabuleiro, ferramentas adaptáveis
à janela e ao retrato, tipografia independente da escala do monitor, foco e
rolagem dos controlos. Y/Nex abrem com o tabuleiro completo e permitem ampliar;
Faísca permite escolher o destino no tabuleiro e limpar a seleção.

A [revisão](../README.md) inclui capturas por jogo e dimensão, reprodução da
falha original e manifesto da build. Passaram 96 perfis de interface e os 18
percursos funcionais, sem erros QML/OOM. As regras/IA em 17 módulos não mudaram.
Build local atualizada em `build/crjm-complete/run-crjm.sh`; anterior preservada
em `build/crjm-before-ui`. Sem publicação ou declaração de testes físicos.
