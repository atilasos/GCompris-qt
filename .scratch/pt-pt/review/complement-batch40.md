# Complemento independente — batch 40

Base `44503ab92`; tip `12011a2641d60fb690becb9146c70d8747d20bb6`.
Revisão limitada às duas fatias indicadas; não revê a tarefa 37.

## Standards — tarefa 38

Sem violações documentadas ou smells que justifiquem alteração nesta fatia.
`AGENTS.md` e `docs/agents/{domain,issue-tracker,triage-labels}.md` foram
consultados; não há CONTRIBUTING/CODING_STANDARDS nem glossário nesta árvore.

A mudança no corpus limita-se a nove espaços exteriores, preservando as chaves,
acentos e texto interior. `corpus.py` audita NFC, espaços e as duas coleções sem
importar os loaders do jogo. A publicação de `items.numberOfLevel = maxLevel`
fica junto do cálculo existente de `maxLevel`, sem introduzir outro contador.
A prova Qt verifica o valor público 23 e conserva o resultado anterior 0.
As pequenas contagens fixas nos testes funcionam como referência independente;
não constituem abstração especulativa ou duplicação relevante.

## Spec — tarefa 34 parcial

Sem erro de implementação nem scope creep identificado. A concordância «usa»
corresponde à exigência de ajuda em português europeu (spec, linhas 27–29).
A mudança da quarta massa de 1 para 2 remove um bloqueio geral ao equilíbrio de
5, explicitamente abrangido pelas linhas 39–40. Preserva os quatro alvos e a
restrição de usar só o prato esquerdo: 5 torna-se 1+2+2 e 4 torna-se 2+2.

Os casos Qt usam rótulos visíveis, arrastos e teclas; não atribuem equilíbrio ou
respostas. Os resultados red/green conservam o mesmo caso, quatro puzzles no
verde e rejeição de resposta errada. O auditor separado enumera as somas legais
e controla as contagens dos 666 alvos; o controlo negativo repõe a massa antiga.
Isso sustenta esta correção concreta, não o funcionamento de todos os puzzles
(spec, linhas 30–35 e 49–52). O tracker e os relatos mantêm essa distinção e
`Progress: claimed`.

Continuam pendentes os percursos completos de 34, Windows 10, dispositivos e
revisão docente final (linhas 41–45 e 54–55); são critérios globais expressamente
não declarados concluídos nesta fatia.

Achados acionáveis: Standards 0; Spec 0.
