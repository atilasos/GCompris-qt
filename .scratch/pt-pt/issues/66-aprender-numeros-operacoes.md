# Aprender números, adições e subtrações em PT-PT

Status: ready-for-agent
Progress: ready-for-review
Type: task
Blocked by: 02, 25

## Aceitação

Inventariar os dados de learn_digits, learn_additions e learn_subtractions e
concluir níveis, datasets e modos. Oráculo inteiro independente pelos números,
operandos e quantidades realmente desenhados. Não obter respostas de modelos
ocultos ou motores. Verificar representações distintas expostas e entradas
reais por rato/teclado conforme a interface.

Acertos, erros, Score/Bonus, transições naturais, configuração persistida,
reinício, ajuda PT/Escape, foco e menu. Copiar/conferir recursos QRC e dados.
Usar snapshot privado offline e supervisor pós-espera, preservando saídas Qt
e externas separadamente. Casos idênticos vermelho/verde para defeitos.

Auditor reproduzível com fontes/catálogos/casos/lançador/supervisor/recursos
fixados em Git ou arquivo imutável, não um manifesto que se possa recalcular.
Testes de cópia independente e adulteração com hashes recalculados. As vozes
existentes têm inventário; descodificar áudio não equivale a ouvir ou aprovar.

Aceitação global, Windows 10, dispositivos físicos, audição e revisão docente
continuam pendentes.

## Progresso

Os 11 processos supervisionados terminaram com saídas externas/nativas 0.
Passaram todos os 17 níveis originais/112 perguntas, repetindo os algarismos
nas três representações: 35 conclusões de nível, 220 perguntas certas e
220 erradas, com 35 Bonus naturais. Controlos, teclado, configuração
persistida, reinício, ajuda, foco e menu passaram. Sem alteração de produção.

Inventário de 33 recursos, 12 áudios descodificados, 220 screenshots conferidos
por píxeis, fontes Git/PO/casos/launcher/supervisor arquivados e snapshot
independente de 269 ficheiros. Oito testes de oráculo/cópia/adulteração passaram.

## Answer

[Provas, reprodução e limites](../functional-learning/README.md).
Linux cobre os percursos descritos, sem certificar áudio por Tab/botão de voz,
audição, dispositivos físicos, outras geometrias, Windows ou aprovação docente.
O interruptor de vozes tem prova de persistência; não uma segunda campanha
completa de cada representação com esse interruptor inativo. Critérios globais
continuam pendentes.

## Integração

Provas integradas; aguardam revisões independentes Standards e Spec.
`ready-for-review` não constitui resolução final nem aceitação global.
