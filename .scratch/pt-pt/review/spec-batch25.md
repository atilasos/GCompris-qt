# Revisão Spec incremental — lote25

Âmbito fixo: `git diff 1ac947fbcf3ea2e2184849daf6c7f64ee6e6e23e...fb787df936325e5a5d929e572a2dbb4927a80e5c`, respetivos commits, spec, tarefas13/19–26, mapa, procedimento e matriz. Tarefa27 excluída. Revisão sem alterações ao código/build.

**Não identifiquei novos achados acionáveis; confiança moderada.** Não executei novamente os casos nativos extensos nem a instalação PE Windows.

**Requisitos/provas:** spec33–35 exige “Cada conclusão é sustentada por evidência; abrir uma atividade não chega.” Os claims novos distinguem corretamente conclusão funcional de leitura/palavras, regressão delimitada de despacho e arranque instalado. A tarefa22 documenta17 motores corrigidos, quatro controlos negativos e dois falsos positivos; não declara os restantes48 handlers ou todos os inputs aprovados. Os casos observam objetos reais com eventos Qt; a substituição de `menu.home` limita a prova à fronteira de navegação, de forma coerente com o âmbito publicado. A matriz mantém os estados pendentes.

**Implementação:** os17 handlers consomem as teclas enumeradas sem alterar ActivityBase globalmente; Escape continua fora dessas listas e Ctrl+W é preservado em submarine. A leitura elimina todas as ocorrências do alvo nas rondas negativas, repõe alternativas e publica o número real de níveis. Não encontrei comportamento novo demonstravelmente errado.

O snapshot25 copia symlinks transitivamente, verifica conteúdo/identidade antes/depois e rejeita adulterações. A substituição dos dois recursos privados da checkout é explícita; as bibliotecas Qt do sistema não são declaradas fixadas. As tarefas21/23 continuam abertas, sem transformar sessões positivas em prova de ausência dos encerramentos intermitentes.

**Âmbito:** correções de teclado/leitura e categorias traduzidas satisfazem spec27–29 e39–40 (“Erros gerais que impeçam jogar ou concluir uma atividade são corrigidos”). As categorias preservam os IDs/filtros e abrangem os33 tokens inventariados. Sem scope creep material.

A fronteira NSIS usa destino nativo, `/D=` final e verificação do executável; o fixture PE real está corretamente distinguido dos testes Linux e da entrega aprovada. O pacote de audição26 conserva bytes/licenças, transcrições e32 estados pending, apoiando spec41–42; a verificação HTTP local não é apresentada como prova de `file://`/Windows.

**Verificação repetida:** quatro testes snapshot, três pacote-áudio e quatro Node leitura/categorias passaram. Suite candidato: dez testes, oito passaram e dois ignorados por dependências ausentes. CI38807970526 corresponde à revisão anterior dfc26b730; não comprova os17 fixes/categorias finais.
