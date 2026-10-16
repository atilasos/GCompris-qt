# Ordenar letras, números e frases em PT-PT

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 02, 25

## Aceitação

Inventariar todos os dados e concluir todos os níveis/modos de
ordering_alphabets, ordering_numbers e ordering_sentences no Qt real PT-PT,
sem rede e com recursos privados. Ordenar pelos rótulos visíveis e regras
independentes, sem consultar solução/expectedAnswer, chamar validação ou
escrever estado de jogo. Arrastos reais, erros rejeitados, acentos/maiúsculas
quando aplicáveis, ajuda, navegação, configuração persistida e menu.

Verificar dados e recursos de todos os níveis. Corrigir defeitos reproduzidos
com vermelho/verde. Preservar provas/comandos/hashes e limites de amostragem,
áudio, Windows e revisão docente. Não repetir ordering_chronology já coberta.

## Answer

Os seis recibos Qt finais passaram com perfis novos PT-PT, sem rede e com
269 recursos físicos privados. Concluídos todos os 36 níveis originais:
8 números, 8 letras e 20 frases, nos 16 conjuntos disponíveis. Houve 36
ordens erradas rejeitadas, 636 arrastos de jogo, três reordenações no destino
e três arrastos parciais adicionais reiniciados pela configuração.

Os oráculos leem rótulos desenhados, com comparação numérica, alfabeto a-z e
frases PT completas independentes da solução do motor. Verificados Bonus,
bordos, progressão natural, configuração persistida, ajuda, navegação, foco
e menu. O fundo carregou e os seus bytes QRC coincidiram com o SVG original.

A auditoria do catálogo compilado reproduziu quatro frases fora das bandas
explicitadas nos comentários. Corrigidas só essas quatro frases e os dois
objetivos PT inclusivos. O JS de produção não mudou. O relatório e auditor
estão em `../functional-ordering/README.md` e `tests/functional_ordering/`.

Os conjuntos aleatórios têm uma amostra nativa por nível, além do inventário
completo de dados. Não se certificam todas as permutações linguísticas,
Windows, toque ou áudio físico. Revisão docente permanece pendente, incluindo
as quatro frases corrigidas. A matriz global mantém aceitação própria.
