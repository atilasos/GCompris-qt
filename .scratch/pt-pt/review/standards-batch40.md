# Standards incremental — lote40

Intervalo fixo: `git diff 44503ab92...12011a2641d60fb690becb9146c70d8747d20bb6`.
Fontes: AGENTS.md, README.md, convenções locais e heurísticas Fowler da skill code-review.

**Exclusão de independência:** não revi a tarefa38, da minha autoria: corpus PT, contador de letter-in-word e respetivos testes/provas. Requer complemento independente.

Nos restantes lotes34/37/39/40: zero findings Standards. As alterações de produção são pequenas e seguem os padrões existentes: uma massa ajustada mantendo valor/etiqueta coerentes, mensagens PO corrigidas sem tocar nos identificadores traduzíveis e propagação explícita do nível/total público no solitário.

O auditor das balanças usa Decimal e alcançabilidade matemática sem importar o resolvedor visível; a regressão reintroduz o conjunto de massas original numa árvore temporária. Os testes nativos observam os componentes reais e as interfaces públicas: entrada, reprodução, navegação e contagem. A procura da árvore visual fica confinada aos adaptadores de teste e não introduz Message Chains ou Feature Envy na produção. A estrutura dos helpers de controlos segue a convenção já usada no fork; a repetição não justifica uma abstração nova neste intervalo.

Os relatórios distinguem provas parciais, contratos e execução completa. Os baselines vermelhos não são apresentados como aceitação final. Não encontrei violação documentada, generalidade especulativa, mudança dispersa injustificada ou contribuição upstream contrária ao README.

A revisão Standards não converte os checkpoints parciais em conclusão dos jogos nem substitui a revisão Spec.
