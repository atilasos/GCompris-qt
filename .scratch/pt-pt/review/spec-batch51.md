# Spec da tarefa 51

Implementação `2f650ff18dcb0ac91a15b037ee9f093bb8b5c568`, merge
`85f63b682437e390cc5184a070eb136483cd0d46`. Revisão independente da lacuna
P2 de Spec49, ticket 51, caso, auditor e recibos. Sem novas campanhas ou
alteração do índice. A tarefa 46 da minha autoria está excluída.

O P2 está resolvido. Os dois casos curtos têm resultado positivo, código zero,
sem timeout ou erros QML. O disco inferior é escolhido pela posição vertical
visível. Cada gesto começa no seu centro desenhado, através do background da
atividade, sem envio artificial para um item disabled. Enquanto está coberto,
o seu disco e MouseArea estão desativados e conservam pai e posição. Os
snapshots antes/depois também conservam os restantes discos, exceto o topo
realmente arrastado.

Os dois redirecionamentos clássicos e os três simplificados expõem o inferior.
Depois, o teste confirma enabled e move esse mesmo disco através da mesma
região visível. Isso demonstra a restrição pedida, admitindo o comportamento
real da MouseArea expandida, que pode direcionar o gesto ao topo permitido.
Não se exige pilha inteira imóvel quando outro disco legalmente se move.

Conferi que o caso corresponde ao SHA dos novos recibos e executei apenas a
função de auditoria em leitura, sem o seu ponto de entrada que escreve índice.
Os seis casos e 34 hashes coincidem com o índice conservado. Os 28 hashes
anteriores também coincidem com o índice original de 49 e com os ficheiros
atuais. Não há repetição das nove campanhas nem alteração de produção.

O vermelho de contrato excessivamente estrito permanece como diagnóstico,
fora da aprovação. Ticket e README explicam a revisão desse contrato, sem
inventar um defeito do produto. Os limites de Windows, hardware, touch/mobile,
áudio físico e revisão docente de 49 mantêm-se. Não encontrei novo achado
acionável nesta correção delimitada.
