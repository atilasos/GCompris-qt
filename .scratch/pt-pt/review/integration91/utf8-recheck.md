# Spec recheck — suplemento UTF-8 da tarefa 91

Base: `ad0a4508a`; head: `397ca3e74545c44c8efa3c5988b468020ccbfc3a`.

**Findings acionáveis: 0.** As duas leituras CLI de `assets-lock.json` e `completion.json` especificam agora `encoding="utf-8"`. A seleção de pares, hashes, dimensões, invariantes e verificação física permanecem inalteradas.

Executei independentemente `PYTHONDONTWRITEBYTECODE=1 PYTHONPATH=tests python3 -B -m unittest -v test_voice_container_policy.PackageCliEncodingTest`: **1 teste com duas orientações passou**, retornos CLI 0 e `passed:true`. O teste executa a entrada real via `runpy`, com a abertura de texto sem encoding simulada como cp1252, e alterna a representação de «carraça» literal UTF-8 versus escapes Unicode entre lock e conclusão. Os recursos físicos da fixture são lidos pelo verificador real. O fixture copia o script para temporário e não altera o repositório.

Os logs red preservados demonstram as duas rejeições do manifesto antes da correção; o green demonstra aceitação após as duas leituras explícitas. A documentação distingue corretamente esta regressão da falha original: se os dois JSON atuais sofrerem a mesma interpretação cp1252, a igualdade pode continuar a passar. Não se atribui a este suplemento a explicação da diferença física RCC entre plataformas.

Limites: esta revisão não executou Qt, build, Windows, instalador, áudio nem publicação. A execução Windows CI e a publicação pedidas na tarefa 91 continuam necessárias para o seu fecho. Nenhuma alteração no repositório foi feita nesta revisão.
