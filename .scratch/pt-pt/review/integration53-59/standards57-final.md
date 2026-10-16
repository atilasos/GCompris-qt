Standards FINAL57, intervalo fixo `b30c412...994d3c65c4f37a841f63bcca9ae183dfa01e9ee1`. Checkpoint PO anterior excluído.

- **P2, confiança alta, identidade do fonte/catálogo não ligada ao recibo** — `tests/functional_gnumch/audit.py:12–22` verifica caso e launcher arquivados, mas ignora source_sha256 e portuguese_catalogue_sha256. O manifesto frozen-source já contém os hashes exatos de ambos. Reprodução somente em memória: alterei esses dois campos para zeros no recibo final equality-01; a auditoria completa continuou a devolver passed=true. Comparar cada campo com os bytes históricos arquivados pertinentes, conservando separadamente os estágios anteriores dos red/green; acrescentar negativos CLI para ambas as identidades. Não usar o PO atual como referência de provas históricas.

**Prova atual:** os21 recibos finais correspondem aos hashes do índice e têm Qt0; conferi independentemente que os seus hashes de fonte e catálogo correspondem ao manifesto congelado. Não há divergência real nesses21 casos. O achado afeta a capacidade do auditor para rejeitar futura corrupção/inconsistência dos metadados.

Os sete testes e a auditoria pura passaram104 níveis e1874 capturas corretas. O executor reclama saídas novas, valida limites e espera retornos reais; a campanha fixa exige11 resultados. A atribuição de withMonsters agora segue spawnMonsters em cada nível, depois de stopLevel parar temporizadores/destruir inimigos; não encontrei regressão concreta nesse hunk.

**Violações documentadas adicionais:** nenhuma. **Smells:** nenhum adicional relevante. Amostragem, controlos/monstros, estágios antigos e limites de Windows/hardware/áudio/docente continuam explícitos.

Sem Qt, alterações de código/build, índices ou provas. Testes usaram temporários; a corrupção de demonstração foi injetada apenas na leitura.
