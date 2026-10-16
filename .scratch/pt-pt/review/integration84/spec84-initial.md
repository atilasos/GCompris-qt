# Revisão Spec independente — tarefa 84

Intervalo fixo `85dc3273d3763aa4b577a2869e127b217e3c5538...3a2d9391c6cc3593b337b0bbf2323e2661213c55`; commits e diff revistos. Sem Qt/build/push ou alterações de capturas.

**P2 — Primazia histórica falsa permanece no texto revisto do Coliseu; confiança alta.** Ticket84:19–21 exige verificar textos e «Declarar lacunas ou ambiguidade, sem aceitar automaticamente qualquer tradução existente». Em `poqm/pt/gcompris_qt.po:8804`, o parágrafo reescrito afirma «Foi o primeiro anfiteatro permanente de Roma». A ficha arqueológica do [MARQ/Museo Nacional Romano](https://marqalicante.com/gladiadores/portfolio-item/inscripcion-funeraria-del-portero-del-anfiteatro-statilius/) identifica o anfiteatro de Statilius, construído em 29 a.C., como primeiro anfiteatro em pedra de Roma; o [turismo oficial de Roma](https://www.turismoroma.it/it/node/1155) data a construção do Coliseu de70–80d.C. É um erro herdado da fonte inglesa, preservado na revisão, não um facto novo inventado. A revisão publicada não o assinala como lacuna.

Remédio: retirar a primazia falsa ou substituí-la por descrição factual sustentada; acrescentar fonte e par lexical idêntico vermelho/verde num suplemento dirigido, preservando as três raízes históricas e sem repetir as quatro campanhas.

Restante âmbito examinado é coerente. O oráculo regista os painéis realmente abertos, títulos/descrições/fotografias/áudio e posições visíveis. Responde por nomes ou significado ensinado, localizando depois a imagem pela geometria; não lê ordem/IDs corretos de modelos. A identificação de áudio é técnica, sem alegar audição humana. As correções factuais verificadas de Khufu e Meidum concordam com as fontes primárias egípcias indicadas.

Auditor confirmou14 mapas/98 apresentações/116 perguntas/16 erros reparados/30 avanços, quatro controlos e composição de24 recibos/nove pares idênticos. Ajuda/Escape/foco, navegação/extremos, reinício parcial, repetição sonora e menu são exercidos; configuração ausente é explicitada. Suplementos corrigem painéis sem fingir repetição de campanhas. Apenas86 mensagens PO mudam, sem scope creep de motor.

Comandos observados: `audit_all.py` e onze testes normal/`-O` passaram. `portable.py` executou os onze testes isolados nos dois modos com retornos0; a gravação final do relatório existente foi recusada por criação exclusiva, sem o alterar. Fontes/RCC/QM/extrações, âncoras e retornos separados estão vinculados fisicamente. Sons descodificados não herdam aprovação32. Windows, hardware, audição, docente e aceitação global permanecem pendentes.
