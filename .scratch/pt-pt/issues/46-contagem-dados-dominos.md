# Validar contagem de objetos, dados e dominós em PT-PT

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 02, 25

## Aceitação

Completar todos os níveis/datasets e modos expostos de enumerate, smallnumbers
e smallnumbers2. Distinguir contagem de pontos do dado e soma dos dois lados do
dominó; o oráculo usa o que é desenhado/visível, não respostas do motor.
Verificar resposta certa e errada, teclas físicas/visuais, transições e Bonus.
Em jogos com tempo, deixar ocorrer uma perda real e recuperação, operar as
velocidades expostas sem encurtar temporizadores nem imobilizar os objetos.

Nos objetos, testar arrasto real para organizar e ambas as opções de validação
quando expostas. Ajuda PT, navegação, configurações/reinício, foco e menu em
cada motor. Inventariar todos os dados e recursos reais, com auditor independente.

Qt original, perfil novo offline e cópia privada de recursos. TDD para defeitos,
vermelho/verde reproduzível. Sem aprovar Windows, touch/mobile, dispositivos
físicos, audição ou revisão pedagógica global por estes testes.

## Answer

14 recibos Qt finais positivos, todos os processos terminados. A campanha
principal completa 848 puzzles: 128 de frutos em duas validações, 144 de dados
e 576 de dominós nas quatro representações. Quatro tracers separados com
teclado visual desativado completam 174 puzzles dos primeiros três níveis por
modo, sem alegar segunda campanha completa.

Os seletores reais confirmam quatro datasets/14 níveis nos frutos e oito
datasets/nove níveis em cada jogo temporizado. Controls opera velocidades
1–10 pela UI com persistência/movimento, perda natural e recuperação nos dois
motores, ajuda PT, navegação/reinício/foco/menu. Não cobre o produto cartesiano
de velocidades com todos os puzzles. Oráculo independente lê imagens/pontos/
rótulos visíveis e compara os 335 ficheiros expostos nos cinco RCC à fonte.

Sem alteração de produção. TDD do oráculo e vermelho/verde de prontidão do
arrasto corrigem apenas o teste. Diagnósticos negativos ficam fora do índice.
Som físico, Windows, hardware, touch/mobile e revisão docente continuam
pendentes. Provas e limites em `../functional-counting/README.md` e `index.json`;
runner e instruções em `tests/functional_counting/README.md`.
