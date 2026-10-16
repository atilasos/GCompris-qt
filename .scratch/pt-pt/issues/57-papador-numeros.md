# Cinco variantes do Papador de Números em PT-PT

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 02, 25

## Aceitação

Inventariar e concluir níveis/datasets/modos de gnumch-equality,
gnumch-inequality, gnumch-factors, gnumch-multiples e gnumch-primes.
Escolher células pelos números/expressões e pedidos realmente visíveis,
com aritmética/comparação/divisibilidade/primalidade independente.
Movimento e captura por entradas reais, erros, vidas, monstros/perda e
recuperação quando expostos, Bonus/transições, configuração, ajuda PT e menu.

Não ler listas de respostas/validadores do motor, escrever progresso ou
imobilizar inimigos/temporizadores. Corrigir defeitos só após reprodução
nativa vermelho/verde. Recursos e dados de todos os níveis, snapshot privado
offline e provas/hashes. Não certificar Windows, hardware, som ou docente.


## Answer

Concluídos104 níveis finais:40 igualdade,40 desigualdade e8 fatores/múltiplos/
primos. Auditor independente confere1874 capturas certas,28 avisos e cobertura
integral de níveis. Cinco casos extras de monstros perdem e recuperam o nível,
sem encurtar temporizadores; cinco controlos cobrem ajuda/foco/menu/reinício e
seletores reais quando expostos.21 recibos finais Qt/launcher0, sem timeout ou
erros QML. Nove testes Python/CLI passam,50 recursos Qt conferidos e dois WAV
descodificados por software.

Corrigidas três traduções reproduzidas e a flag de monstros que não regressava
a false nos níveis/datasets sem inimigos. Pares nativos antes/depois preservados.
Após o JS corrigido,104 níveis foram executados de novo com fontes/snapshot
privados selados. Baseline anterior não duplica contagem. Evidência, arquivos,
comandos e limites em `../functional-gnumch/README.md` e index.json.
Windows/hardware/audição/docente permanecem pendentes; sem conclusão global203.


Revisão FINAL57 P2 corrigida: os44 recibos são ligados ao QML e aos quatro
PO históricos arquivados, com validação dos dois hashes pelo auditor. Três PO
anteriores reconstruídos por inversão das traduções documentadas coincidem
exatamente com os hashes das execuções. Todos os44 recibos, incluindo21 finais,
conservam os bytes. Nove testes passam, incluindo negativos CLI e cópia isolada
sem os caminhos originais; sem repetir Qt. Ver `identity-review/` na evidência.

## Fecho de revisão

O recheck Standards confirmou o P2 fechado na integração `9e7c0a0db`, após
nove testes e conferência dos 44 recibos byte a byte. Relatórios inicial e
final em `../review/integration53-59/`. Resolução limitada à prova Linux;
Windows, hardware, audição e revisão docente mantêm-se pendentes.
