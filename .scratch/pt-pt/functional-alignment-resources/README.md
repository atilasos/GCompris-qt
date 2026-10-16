# Recursos físicos suplementares — revisão P2 da tarefa 80

O arquivo original `functional-alignment` permanece byte a byte intacto. Este suplemento recupera os **39 RCC instrumentados e os QM correspondentes aos 39 recibos históricos**, incluindo as quatro campanhas completas e os dois consumidores do verde final de teclado. Cada binário só foi aceite depois de o SHA-256 completo coincidir exatamente com o SHA já existente no recibo. Não houve novos jogos nem novas conclusões nativas.

`resources.zip` guarda 340 objetos físicos deduplicados: binários RCC/QM, ficheiros extraídos realmente por Qt QResource, catálogos TS descodificados a partir dos QM e a fonte histórica do inspetor. `resources.json` liga cada recibo/caso ao seu override e cada caminho extraído aos bytes guardados. Preserva igualmente os cinco RCC canónicos (core e quatro atividades) em cada um dos três snapshots históricos: 15 mapas, com binários físicos. Os restantes recursos do snapshot continuam identificados pelo manifesto histórico; este suplemento centra-se na cadeia core/quatro atividades e nos overrides efetivos, sem arquivar a totalidade dos 269 ficheiros de runtime.

## Recuperação exata, sem nova partida

Os deployments antigos tinham sido apagados; não se afirma que sobreviveram. Permaneciam as fontes Git congeladas e os snapshots físicos privados. A reconstrução repetiu a transformação histórica do launcher: fonte QML exata, mesmo caso e substituições históricas dos caminhos de saída/fonte como strings, prefixo `import QtTest`, mesmo QRC e ferramentas Qt locais. Algumas pastas de diagnóstico tinham sido renomeadas depois da execução; os nomes originais são preservados no relatório e a igualdade integral do SHA decide se estão certos.

O RCC contém o timestamp do QML instrumentado. Só esse campo de oito bytes foi procurado numa janela finita de 120 000 milissegundos anterior ao timestamp de metadata de cada recibo. A busca não adivinha conteúdo: só aceita um resultado cujo SHA completo seja o original. Fontes, caso e conteúdo extraído são verificados separadamente. Os dois QM foram recompilados dos catálogos históricos, ambos com SHA original exato. Não houve leitura de memória, recuperação de disco, manipulação de processos ou tentativa de provocar falhas.

O inspetor histórico `tools/pt-pt-audio/rcc_inventory.cpp`, também arquivado, registou cada RCC por `QResource::registerResource`, leu e exportou os ficheiros reais para uma árvore privada; os bytes dessas exportações estão no ZIP. Cada QML instrumentado é comparado, pelo auditor, com a fonte histórica e o caso exato reinjetado, sem abrir qualquer caminho histórico. Cada outro ficheiro extraído é comparado com a fonte histórica pertinente. Os QM físicos são confrontados com os SHA dos recibos e têm extrações TS físicas preservadas.

As duas primeiras tentativas de reconstrução recusaram diagnósticos cujos nomes de saída históricos ainda não tinham sido restituídos. Os logs ficam preservados; não foram escritos recursos suplementares finais a partir dessas tentativas. A terceira tentativa recuperou os 39 casos. Estes testes de reconstrução só executam ferramentas de compilação/extração de recursos; não iniciam a aplicação nem QtTest.

## Verificação portátil

```sh
python3 tests/functional_alignment/audit_resources.py
python3 -m unittest discover -s tests/functional_alignment -p 'test_*.py'
```

Para verificar uma cópia sem Git, Qt, build ou caminhos antigos, copiar os dois diretórios de prova e os três ficheiros `audit_resources.py`, `audit.py`, `oracle.py`; executar o primeiro com `--original COPIA_ORIGINAL --supplement COPIA_SUPLEMENTO`. Primeiro verifica-se a prova histórica com a âncora original, depois o suplemento com uma nova âncora SHA literal externa ao ZIP. Corrupção de RCC, QM, QML extraído, objeto ausente e reencadeamento coerente de bytes/mapas/selo são recusados. Python `-O` é recusado explicitamente.

A reconstrução pode ser repetida apenas enquanto existirem as fontes/snapshots privados correspondentes, através de `reconstruct_resources.py --output DIRETORIO_NOVO`. Essa conveniência de reconstrução não é uma dependência da auditoria: o ZIP suplementar é físico e autocontido em conjunto com o arquivo original. O comando recusa uma saída existente.

Mantêm-se a composição histórica das 42 partidas e todos os limites da prova original. Windows 10/11, dispositivos físicos, audição, acessibilidade, pronúncia e revisão docente/global continuam pendentes. Nenhuma voz, aprovação, CSV, mapa, build principal ou recibo antigo foi alterado.
