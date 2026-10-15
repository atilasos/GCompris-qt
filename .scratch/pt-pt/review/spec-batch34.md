# Revisão Spec — conclusão das balanças34

Âmbito fixo5ef7db807...599ed851b018a3ea5c2b81c94c3941b2d38d45b7, delimitado à tarefa34. Inspecionados harness, oráculos, nove recibos finais, snapshot, casos e limites. Sem alterações ou repetição da campanha Qt.

**Sem novos achados acionáveis; confiança moderada/alta.** Não encontrei implementação aparente errada, desvio de âmbito ou nova aprovação sem suporte.

Spec30–35 exige conclusão dos níveis/modos, respostas certas/erradas e que “Cada conclusão é sustentada por evidência”. Conferi os hashes dos nove relatórios e respetivos case.qml: todos coincidem com o índice, têm sucesso/saída0 e ausência de erros QML. Reexecutei a auditoria independente sobre os três recibos completos:666 puzzles,142 níveis,142 negativas e4018 arrastos.

O solver lê os rótulos dos pesos visíveis e o texto visível do presente. Nos alvos ocultos enumera somas atingíveis e observa a inclinação `needle.angle`; não lê giftWeight, question.answer ou alvos do dataset para escolher a solução. A conclusão usa arrastos, entradas e OK/Enter reais. A auditoria Python/Decimal recalcula somas assinadas, unidades SI/imperiais, direção das tentativas e valor digitado na unidade pedida. A auditoria estática de alcançabilidade dos dados é separada do solver UI.

As negativas preservam o subnível e obrigam à recuperação antes da solução; os controlos exercitam ajuda PT, mudança de nível, reinício por Gravar após arrasto parcial e menu. A preferência de teclado visual está ligada na campanha completa; os três casos adicionais com a preferência desligada são explicitamente tracers de apenas três níveis por jogo/24 puzzles. Não são apresentados como outra campanha completa ou validação de teclado físico.

A identidade inclui os269 ficheiros do snapshot e hashes de binário, fontes, catálogo e casos; os relatórios distinguem os RCC reconstruídos privadamente. As duas correções de produção já revistas permanecem as únicas: concordância do título SI e peso do puzzle impossível. Satisfazem spec27–29 e39–40; sem funcionalidades novas.

Verificação curta repetida: cinco testes do auditor, dois de alcançabilidade e exemplos Node passaram. Limites de orientação, dispositivos físicos, áudio, Windows e revisão docente estão declarados; não foram relistados como defeitos novos deste lote.
