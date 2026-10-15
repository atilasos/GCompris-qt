# Ordenar letras, números e frases em PT-PT

Status: ready-for-agent
Progress: claimed
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

## Progresso — dados

O inventário Qt inicial confirmou as 20 frases efetivamente traduzidas.
A auditoria independente através de lconvert detetou quatro frases fora dos
intervalos explícitos nos comentários dos conjuntos: futebol7 (máximo5),
Sol5 e sair4 (mínimo6), família12 (máximo10). A correção mantém os20 níveis,
ajusta só essas quatro frases e torna inclusivos os objetivos «Até5/10
palavras». Vermelho/verde em `functional-ordering/data-{red.log,green.json}`;
a revisão docente de clareza e das frases alternativas permanece pendente.

Campanhas de arrastos completos e provas finais ainda em execução; esta
fatia não declara a tarefa resolvida nem aprovação global de jogos/Windows.
