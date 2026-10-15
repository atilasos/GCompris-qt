# Validar leitura horizontal e vertical na aplicação Qt

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 02

## Aceitação

- Verificar os três níveis portugueses partilhados e as duas direções de leitura.
- Concluir dez perguntas por nível com cliques reais e temporizadores/animações normais;
  observar alvos presentes e ausentes e rejeitar respostas erradas.
- Verificar escolha PT no primeiro arranque e com configuração explícita, velocidades,
  reinício, níveis anterior/seguinte, ajuda e regresso ao menu.
- Validar todos os dados com JavaScript real; reproduzir defeitos antes de os corrigir.
- Manter RCC/perfis privados e registar limites de Linux, Windows e revisão humana.

## Answer

Validação Linux do lote concluída: quatro casos nativos offline passaram,
30 acertos/3 erros/3 níveis por atividade, dez velocidades e controlos completos.
Dados reais verificados com nove fluxos RNG determinísticos. Corrigidos perda de
palavras, alvo duplicado nas rondas de ausência, contagem de níveis e «música».
Evidência, reprodução e limites em `../functional-reading/README.md`.

Os dois encerramentos iniciais código 139 não voltaram a reproduzir-se com o
caso completo original nem no replay de 90 s do source inicial. A causa continua
por demonstrar; a tarefa resolve a implementação/prova deste lote, não a
incerteza de falhas intermitentes ou a aceitação global da especificação.
Windows, escola e revisão do professor permanecem pendentes na tarefa 06/08.
