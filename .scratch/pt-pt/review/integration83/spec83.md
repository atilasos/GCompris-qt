# Revisão Spec independente — tarefa 83

Intervalo fixo `f7986cc22788e78a8fdbb8be82ae5bf92308b546...d593cfb5086caa714ebd2d440ee1a4cc4c4b449d`. Sem Qt/gdb/stress/build, alterações de main/provas ou novas campanhas.

**Sem achados acionáveis no handoff; confiança moderada/alta. O objetivo de descobrir a causa permanece incompleto.**

Ticket83 exige: «Se a causa continuar desconhecida, documentar a incerteza e manter a tarefa aberta». Ticket, README e auditor cumprem-no: `Progress: open`, `reproduced: false`, `cause_known: false`, `issue_resolved: false`. A spec35 pede «Cada conclusão é sustentada por evidência»; não há conclusão de estabilidade ou correção fabricada a partir dos seis resultados0.

O diagnóstico é explicitamente finito: duas fases × três modos, seis arranques ociosos, cada recibo com `primary_levels: 0`. O payload de nove registos é fixture histórica, sem representar partidas novas. Os casos de cada modo são byte-idênticos entre fases. Não escrevem respostas, progresso, velocidades ou relógios do produto; não há alterações de produção/framework partilhado neste intervalo.

A seleção física conserva o original81 com nove níveis/asserções0 mas processo139, e três replays0 separados. O README não identifica o PID original por mera coincidência temporal, não atribui causalidade ao OOM que matou outro processo quarenta segundos antes e não transforma o símbolo GC numa culpa demonstrada do Qt. Runtime histórico removido produz disponibilidade0 e inode independente null; o snapshot novo269 tem 26 diferenças explícitas. A tarefa23 é comparação, sem presumir mecanismo igual.

Os ensaios novos vinculam PID/cmdline `/proc`, binário e namespace; o auditor exige também retorno do inferior e ausência de SIGSEGV, além dos retornos separados de wrapper, supervisor/executor e observação externa pós-espera. RCC/QM físicos, extrações instrumentadas, fontes/casos e ferramentas correspondem aos hashes preservados. A âncora literal impede transformar139 em verde por reseal; vazio e identidade falsa são recusados.

Auditorias puras normal/`-O` e onze testes passaram, incluindo cópia física isolada e adulterações. Não executar a sequência histórica completa é um limite declarado dos ensaios autorizados, não um cumprimento fingido do objetivo causal. A aceitação do ticket ainda depende de futura reprodução/stack e hipótese demonstrada; Windows, hardware, áudio, docente e aceitação global continuam pendentes, conforme spec43–45/54–55.
