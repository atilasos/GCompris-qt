# Spec — correção 91

Base: `e4444354e`; head: `4626a8d860dfd584341f569d3bdb1130b2c2fae1`. Diff: `git diff e4444354e...4626a8d860dfd584341f569d3bdb1130b2c2fae1`.

**Findings acionáveis: 0.** A correção respeita «Não substituir a verificação física por confiança no manifesto gerado» e mantém o âmbito dos áudios aprovados.

O lock conserva integralmente `pt_voice_completion` e acrescenta apenas os dois pares completos observados: Linux RCC `766a4650…`/Contents `0a52da45…` e Windows RCC `471e5822…`/Contents `d0a78006…`. O helper compara todos os invariantes comuns com a política externa e só seleciona um par cuja lista inteira coincida. O manifesto gerado não introduz hashes aceites, não mistura componentes e não pode aprovar terceiro par. Os ficheiros físicos selecionados continuam a ser lidos e comparados por dimensão/hash, juntamente com a proveniência fixa. A política comum de aprovação, substituições e contagens não é relaxada.

Inspecionei os quatro novos testes: constroem dois RCC reais com os mesmos 64 recursos sintéticos, verificam inventários iguais/contentores distintos e exercitam aceitação explícita, par não listado, mistura, corrupção física, reseal coerente e alteração de invariante. Não executei estes testes porque compilam/executam utilitário Qt. Executei independentemente nove regressões Python de aprovação/política/fronteiras: todas passaram. Executei ainda 40 verificações da interface de seleção com o lock de produção: dois pares aceites, cada invariante comum alterado recusado, misturas, hash desconhecido e conclusão ausente recusados.

A tarefa exige também «Pipeline Windows completo verde, EXE efetivo verificado por hash, publicação HTTPS em endereço curto testada com conteúdo real». Estas etapas permanecem pendentes do coordenador e estão explicitamente identificadas na tarefa e no suplemento; esta revisão aprova apenas a correção preparada, não o fecho da tarefa 91.

Observação CLI adicional enviada ao coordenador: `lock.read_text()` e `manifest.read_text()` ainda dependem do encoding predefinido. Em cp1252, «carraça» torna-se «carraÃ§a». Como ambos os JSON atuais contêm a mesma codificação literal, esta observação não demonstra por si uma rejeição do candidato atual. Fixar UTF-8 explicitamente e testar a CLI sob locale cp1252 remove a dependência; aguarda recheck do commit seguinte.

Limites: os hashes Windows foram observados na CI anterior; não inspecionei esses bytes nem executei Windows, build, Qt nativo, instalador ou publicação. O suplemento delimita corretamente que a causa exata da diferença entre hosts não foi isolada. Nenhum ficheiro do repositório foi alterado nesta revisão.
