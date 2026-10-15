# Standards — lote33

Comparação: `git diff 4fb61ad75...92a1ac25f6343fae07cbdf2e5225eca3f5bc4bed`.
Fontes: AGENTS.md, README.md, convenções do NumPad existente e heurísticas Fowler da skill code-review.

Sem violações documentadas nem smells relevantes encontrados. A guarda `containerPanel.enableInput` no MouseArea dos dígitos5–9 segue a política já aplicada aos restantes botões e resolve uma responsabilidade do componente comum. Não introduz abstração, caminhos especiais por atividade ou mudanças dispersas nos consumidores.

O teste usa a interface pública de NumPad e eventos reais de rato, verifica os dez dígitos bloqueados e ativos e Backspace, e distingue configuração do componente de resolução de um puzzle. O pequeno helper escolhe o painel por domínio dos dígitos; não é uma generalidade especulativa. As referências aos botões públicos são apropriadas ao teste de um componente visual.

O preparador verifica o snapshot de origem, copia-o para destino novo, compila apenas o core privado e volta a selar o resultado, conservando hashes verificáveis. O caminho Linux de rcc está explícito e é consistente com a prova local delimitada, sem promessa de portabilidade Windows. Os logs documentam vermelho e verde sem substituir as asserções.

README proíbe contribuições AI ao upstream: este lote permanece no fork e não cria MR upstream. A restrição da tarefa28 sobre NumPad não se aplica automaticamente à tarefa33, que reproduz e corrige uma causa comum em âmbito próprio.

Resultado: zero findings Standards; não avalia a aceitação funcional completa das atividades.
