# Recheck Spec — P2 da tarefa 80

Intervalo isolado `3b5875b49067b6b3eaaa2a5dda35118ccd2963f5...633e3beecaf354d5c35b46652809f8348792f48a`. Auditoria e testes puros; sem Qt/build, alterações de provas ou recibos.

**P2 anterior resolvido; sem novos achados acionáveis. Confiança alta.**

Ticket80:25–27 pede «Preservar fontes, catálogo, casos, recursos efetivos» para auditoria física. O suplemento fecha a lacuna: `resources.zip` contém os bytes reais dos RCC instrumentados/QM correspondentes aos 39 recibos, quinze RCC canónicos dos três snapshots, extrações Qt e catálogos descodificados. O auditor confirmou 340 objetos físicos deduplicados e 1244 entradas extraídas.

Em `tests/functional_alignment/audit_resources.py`, cada objeto é confrontado com o próprio SHA integral; para cada caso, o SHA dos bytes RCC/QM é igual ao SHA já selado no recibo histórico. A verificação vai além dos metadados: reconstrói o QML instrumentado com a fonte histórica e o caso exato, incluindo as substituições de caminhos como strings inertes, e compara os bytes da extração. Os restantes ficheiros extraídos correspondem às fontes da fase respetiva. Os quinze mapas canónicos também conservam os hashes históricos. Fonte do inspetor, retorno observado e log da reconstrução estão preservados e vinculados.

A prova histórica continua a passar antes da suplementar; ambas têm âncoras literais externas aos arquivos. O diff não altera nenhum ficheiro do diretório original `functional-alignment`. Passaram os 25 testes, incluindo cópia física, corrupção de RCC/QM/QML extraído, objeto ausente, reseal coerente, preservação do original e recusa de saída existente. `-O` é recusado explicitamente, conforme permitido pelo ticket80:28–29.

O README distingue corretamente reconstrução de sobrevivência dos deployments apagados: a busca finita altera apenas o timestamp RCC e só aceita igualdade com o SHA integral preexistente. Não transforma binários divergentes em recursos históricos, não repete partidas e não atribui execução nova aos 42 jogos antigos.

A spec35 exige «Cada conclusão é sustentada por evidência»: a cadeia física agora sustenta os recursos core/quatro atividades e overrides usados. Os restantes recursos do snapshot continuam apenas inventariados, limitação explícita; não se afirma runtime portátil completo, nem aceitação de Windows, equipamento, áudio, docente ou global.
