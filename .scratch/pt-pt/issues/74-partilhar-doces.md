# Partilhar doces em PT-PT

Status: ready-for-agent
Progress: ready-for-review
Type: task
Blocked by: 02, 25

## Aceitação

Inventariar e concluir todos os níveis/datasets de share, com e sem resto e
nos modos de validação disponíveis. Contar apenas crianças e doces desenhados
e interpretar a instrução PT. Calcular quociente e resto independentemente,
sem soluções, contagens ocultas, client data ou escrita no progresso.
Distribuir por cliques/arrastos reais conforme a interface.

Testar distribuição errada e reparação, Score/Bonus, transições naturais,
reinício, configuração/seleção persistidas, ajuda PT/Escape, foco, navegação e
menu. Conferir os SVG e efeitos/vozes usados, distinguindo descodificação de
audição. Não transferir a aprovação das 32 gravações para outros recursos.

Snapshot privado offline, supervisão após a espera e retornos observados,
fontes/catálogos/casos/recibos imutáveis. Auditor portátil com cópia independente
e ataques de adulteração com hashes recalculados. Falhar com Python -O. Se
houver defeito, preservar caso idêntico vermelho/verde. Não preparar a mesma
pasta de fontes em trabalhadores paralelos.

A aceitação global, Windows 10, dispositivos físicos, áudio e revisão docente
continuam pendentes.

## Answer

146 perguntas concluídas em Qt real offline: 15 níveis dos três datasets,
nos dois modos, 30 erros reparados e Bonus natural. Os modelos aleatórios
foram amostrados uma vez por modo, sem congelar o gerador. Dois casos de
controlos comprovam ajuda/foco/Escape, reinício, navegação após progresso,
configuração e seleção reabertas, instrução e regresso ao menu.

Corrigida a coordenada duplicada do arrasto de doces sem contadores e
restaurado o contexto omitido em instruções PT, com dois pares nativos
vermelho/verde de caso idêntico. SVG carregados em Qt e dois WAV descodificados;
não houve audição nem nova aprovação de gravações.

Arquivo imutável: [functional-share/README.md](../functional-share/README.md).
Auditor normal/-O e 14 testes Python passaram, incluindo cópia portátil e
ataques com hashes recalculados. Verificação em
[functional-share-verification/README.md](../functional-share-verification/README.md).
Nenhum processo pendente; pronto para merger e revisões independentes. Os
limites globais, Windows, equipamento, audição e docente mantêm-se.

## Integração

Provas integradas para Standards e Spec independentes. `ready-for-review`
não representa resolução final ou aceitação global.
