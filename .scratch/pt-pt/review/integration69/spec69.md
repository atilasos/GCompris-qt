# Revisão Spec independente — tarefa69

Intervalo fixo1d62ccafc...fe9f75707; conteúdo combinadoa84b22dc9. Inspecionados spec/ticket, README, produção, casos, oráculos, cápsula e auditores. Sem Qt, edição de mapa/CSV ou escrita de índices.

**Sem achados acionáveis; confiança moderada/alta.**

Spec30–35 exige níveis/modos, respostas certas/erradas e evidência. A auditoria pura confirmou oito casos positivos/um vermelho esperado,76 conclusões de nível,650 comparações,250 sequências,380 negativas e76 Bonus. Os14 testes passaram.

O comparador lê operandos desenhados e usa comparação própria dos algarismos normalizados; a auditoria Decimal recalcula menor/igual/maior, intervalos e precisão. A vírgula está exercitada. Negativos pertencem aos dados de vizinhos, não são inventados como cobertura nativa do comparador. Nos vizinhos, a cadeia de passo um vem das âncoras visíveis; respostas ocultas não orientam os arrastos. O auditor confere lacunas, início da cadeia, instruções portuguesas e plurais.

Os modos automático/manual são escolhidos pela UI e completam25 níveis cada. Há escolhas erradas/reparação e transições naturais, sem escrita de progresso ou encurtamento de relógios. Controlos cobrem reinício parcial, seleção persistida, navegação, ajuda/foco e menu. A persistência demonstrada não é apresentada como aprovação de dispositivo físico.

A alteração de produção publica número total e nível corrente de adjacent_numbers no ActivityBase, sincronizados com o estado real do motor. O mesmo caso vermelho/verde observa0/25 níveis públicos e índice corrente correspondente. É uma correção funcional no âmbito da spec39–40, sem novas funcionalidades.

A cápsula contém262 fontes e dois ficheiros vermelhos adicionais; âncoras externas conferem fontes, catálogo, casos, recursos, snapshot269 e154 artefactos selecionados. Os39 recursos QRC e áudios mantêm identidades. Os três retornos são separados: Qt, lançador pós-espera e ferramenta. Confirmei tool143 no primeiro manual e0 no rerun; o primeiro permanece excluído. Os125 exercícios do rerun substituem os históricos, sem dupla contagem, com o mesmo SHA de caso.

As76 imagens são de fim de nível, explicitamente sem OCR ou prova de píxeis dos380 enunciados. Descodificação WAV não é audição. Linux/software, Windows, hardware, áudio, professor e aceitação global203 estão corretamente delimitados. Sem scope creep ou comportamento novo demonstravelmente errado.
