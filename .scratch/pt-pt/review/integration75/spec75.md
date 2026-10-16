# Revisão Spec independente — tarefa75

Intervalo fixo577556fd8...9d77e71f4ac04b19e074188f679ce8729c6f3f91. Inspecionados spec/ticket, README, produção, oráculo visual, casos, cápsula e auditor. Sem Qt, edição de main/provas ou escrita de índices/mapa/CSV.

**Sem achados acionáveis; confiança moderada/alta.**

Spec30–35 exige níveis/modos, respostas certas/erradas e evidência. A função pura confirmou21 níveis,25 tabuleiros,119 associações,25 trocas erradas reparadas e21 Bonus;13 testes passaram. Os14 positivos/três vermelhos e cinco tabuleiros extra de retrato são separados das contagens principais.

O oráculo usa recursos inspecionados, sem coordenadas de solução: relações semânticas explícitas, nomes PT, IoU de silhuetas e geometria/continuidade de buracos nas imagens. As ações usam imagens/rótulos/centros desenhados e arrastos reais. O auditor reconstrói as relações a partir dos recursos e confere119 centros e50 indicadores de erro por píxeis. Não há leitura de Client/modelos ocultos ou escrita de progresso. As escolhas semânticas, incluindo bola/raquete, permanecem abertas à revisão pedagógica.

As correções de oveiro, natureza-morta e limiar de arrasto correspondem aos três pares idênticos red/green. A conversão passa a comparar centro da imagem e limite do painel no mesmo referencial, corrigindo a recusa de uma peça no destino desenhado. São alterações linguísticas/funcionais no âmbito de spec27–29 e39–40; sem scope creep.

O limite do retrato extra800×801 é explícito: um centro fica coberto pela legenda, o arrasto funciona nessa região, e esse píxel não é declarado um dos119 centros visíveis landscape. Não se generaliza a prova a todas as janelas. Controlos cobrem reinício/navegação, teclado, ajuda/Escape, foco e menu.

A cápsula388 fontes/snapshot269 e captura2116 artefactos têm âncoras imutáveis; retornos Qt, lançador pós-espera, supervisor e ferramenta são ligados separadamente. Recursos QRC268 cópias mantêm bytes originais.

O áudio distingue corretamente MediaPlayer PlayingState/hasAudio de audição. SoundEffect permanece status0/playing=false, sem reprodução certificada. Imagename não atribui voz específica ao oveiro; não há áudio regenerado nem extensão da aprovação32 ou dos pares legados44. Linux, hardware, Windows10, perceção física e aprovação docente/global continuam delimitados.
