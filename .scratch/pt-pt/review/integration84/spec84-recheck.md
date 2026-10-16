# Recheck Spec — correção factual do Coliseu

Intervalo fixo `3a2d9391c6cc3593b337b0bbf2323e2661213c55...7dfc1615486a56294b342a7142f3bd3f1c666a24`. Sem Qt/build/push, alterações de main ou capturas.

**P2 anterior resolvido; sem novos achados acionáveis. Confiança alta.**

Ticket84:19–21 exige verificar textos e «Declarar lacunas ou ambiguidade, sem aceitar automaticamente qualquer tradução existente». O msgstr do Coliseu remove «primeiro anfiteatro permanente de Roma» e a comparação histórica associada; apresenta-o como um dos grandes anfiteatros da Roma antiga. `source-facts.md` regista explicitamente o erro herdado do inglês e as fontes primárias MARQ/Museo Nacional Romano e TurismoRoma já verificadas na revisão inicial. Não substitui o erro por uma nova primazia ou data sem suporte.

O suplemento3 preserva um par lexical byte-idêntico, que abre o painel real pela posição visível, confirma fotografia e título e compara o texto efetivamente apresentado. Ambos os processos Qt terminaram0; vermelho e verde têm retornos externos1/0 separados e vinculados aos recibos/casos. O auditor compara fontes/PO, QM/RCC físicos e extração instrumentada exata, além dos screenshots e marcador Qt bruto. O selo `0b6b17c3…` tem âncora literal externa e é ligado à fonte anterior do suplemento2.

O diff não altera nenhuma das três raízes históricas anteriores. O auditor composto conserva14 mapas/98 apresentações/116 perguntas e os sete pares primários, acrescentando apenas um painel/par ao suplemento3. README explicita26 execuções totais e não atribui nova execução às quatro campanhas nem novos jogos concluídos à prova dirigida.

Comandos observados: `audit_all.py` passou; os14 testes passaram em Python normal e `-O`. Incluem adulteração coerente do PO suplementar, rejeição pela âncora externa e rejeição de conjuntos vazios mesmo com selo confiável. O relatório físico `portable-verification-colosseum.json` regista as14 verificações Docker isoladas nos dois modos com saídas0; não voltei a executar Docker neste recheck. A ferramenta exige uma saída nova antes de preparar a cópia, preservando o relatório anterior.

A spec35 exige «Cada conclusão é sustentada por evidência»: o P2 tem agora correção e prova própria. Scope permanece linguístico/factual, sem motor alterado. Runtime completo, audição, equipamento, Windows, revisão docente e aceitação global mantêm os limites anteriores.
