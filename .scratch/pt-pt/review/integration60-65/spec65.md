# Recheck Spec — tarefa65

Intervalo fixo371d620...827485564f13d74ea54f077ea0f838b8e173b5b2. Inspecionados README/ticket, observações forenses, supervisor, auditores/indexador e âncoras verticais. Sem Qt, alterações ou reescrita de índices.

**Sem novos achados acionáveis; confiança alta para estes contratos de prova.**

Spec33–35 exige que “Cada conclusão é sustentada por evidência”. Os retornos reconstruídos são agora explicitamente retrospetivos, separados dos recibos nativos e de sidecars contemporâneos. Dinheiro liga18 outcomes reais (15zero/3um); calendários liga14 (10zero/4um). A proveniência distingue retorno do coordenador e lista de retornos individuais após wait. Hashes fixos fora do arquivo mutável ligam observações, recibos e casos históricos. Não se deduz saída do lançador a partir de JSON Qt verde.

O supervisor futuro aguarda `subprocess.run` antes de criar o sidecar e devolve o código real do filho; identifica recibo, caso e launcher. A saída deve ser nova. O indexador de dinheiro verifica conclusão externa antes de escrever, usando sidecar novo ou somente as observações históricas exatas. O auditor histórico também rejeita um sidecar adicional contraditório. Calendários permite conferir uma cópia por `--check-only` sem mutação do índice.

As três fases verticais têm manifestos raiz SHA256 fixos no auditor, conjunto exato de ficheiros/bytes e recusa de symlinks. Alterar PO/QML e recalcular coerentemente ligações, recibos e índice deixa de contornar a identidade histórica. Não se cria aprovação funcional nova ou transferível para fontes futuras.

Repeti os38 testes:13 calendários,14 dinheiro, nove verticais e dois supervisor; todos passaram, incluindo cópias portáteis e adulterações. Conferi os1795 ficheiros originais contra os hashes preservados: todos intactos; a declaração mantém97 recibos. Confirmei também dd5a27b9b como ancestral da integração, satisfazendo a dependência Git do supervisor usado na prova64.

Sem alteração de produção, scope creep ou ampliação das contagens funcionais. Windows, dispositivos físicos, audição e revisão docente continuam pendentes; esta tarefa apenas reforça a evidência histórica e os contratos de novas execuções.
