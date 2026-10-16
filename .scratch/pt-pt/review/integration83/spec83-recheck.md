# Recheck Spec — interrupção da matriz 83

Intervalo fixo `d593cfb5086caa714ebd2d440ee1a4cc4c4b449d...b1fc8910591b7287625da0ba90b93f7bdf9ea4a5`. Leitura, auditor e testes puros; sem Qt/gdb/build ou alterações de provas.

**Contrato de interrupção corrigido; sem novos achados acionáveis. Confiança alta.**

O ticket83 exige «Se houver reprodução, recolher stack/core e testar uma hipótese de cada vez» e proíbe «mascarar o sinal». A ferramenta usa agora um único predicado `probe_passed()` para continuar ambos os ciclos e para o veredito final (`tests/penalty_shutdown/run.py`). Só aceita supervisor0 e inferior0, lista de sinais vazia, identidade e cmdline observadas compatíveis, namespace presente e igual. Portanto, SIGSEGV/SIGABRT, saída real não zero ou identidade incompleta interrompem a matriz inteira, inclusive se o wrapper devolver0.

As regressões CLI executam o runner verdadeiro com um supervisor fixture sem Qt. Confirmam que SIGSEGV na primeira sonda lança apenas `baseline-bare`, e falhas na terceira não iniciam a fase seguinte. Cobrem saída139/1, SIGABRT, identidade ausente, cmdline falsa, namespaces divergentes/ausentes, sinais ausentes e falha do supervisor. O controlo saudável executa exatamente seis sondas. Os 14 testes passaram em Python normal e otimizado.

O diff não toca no arquivo `penalty-shutdown`; os casos, recursos, ferramentas arquivadas e recibos históricos permanecem na fase original. O auditor físico continua válido com seis probes históricos0, original139, `cause_known: false` e `issue_resolved: false`.

Ticket83: «Se a causa continuar desconhecida, documentar a incerteza e manter a tarefa aberta». A atualização do ticket satisfaz essa distinção: corrige a segurança do fluxo futuro de diagnóstico, sem declarar resolvido o encerramento, sem fingir novos ensaios reais e sem transformar os seis0 em estabilidade. A spec35/52 exige evidência e impede aprovação de pendências; causa, investigação e aceitação Windows/global continuam explicitamente abertas. Não identifiquei scope creep.
