# Revisão Spec incremental — lote28

Âmbito fixo: diff e commits `75f56f71f7e79d90ce3357d2b643a6cbc51e7774...192747d4ed8c6b686aff6b421d814e3355c56b7f`; spec, tarefas21/23/27/28 e13/07/08, casos e relatórios associados. Sem alterações ao código/build.

**Sem novos achados acionáveis; confiança moderada.** Não demonstrei implementação incorreta, scope creep ou novas afirmações de aceitação sem suporte.

Spec30–35 exige respostas certas/erradas, níveis/modos e evidência interativa. O caso de álgebra resolve os48 níveis com480 respostas corretas e48 erradas através dos controlos reais, alternando teclado visual/eventos Qt e Enter/OK. O oráculo Fraction é externo ao motor e usa os operandos apresentados; o caso não chama o validador nem atribui pontos. Configurações verificam as dez velocidades, reinício e expiração real. O helper de Algebra consome apenas dígitos/Backspace e passa press/release ao NumPad, preservando os restantes atalhos.

As alterações dos quatro consumidores adicionais respeitam as fases: os decimais editam apenas o resultado com separador disponível; balanças apenas com pergunta visível; cálculo de complementos apenas em modo input. Os dez casos provam a fronteira de edição e atalhos, com fixtures de representação/peso explicitamente declaradas. Não são apresentados como resolução de todos os puzzles. A documentação diz corretamente que a rede não foi bloqueada nestes casos NumPad.

O replay de memória corresponde aos34 percursos/180 pares certos/42 errados, com escolhas pela semântica apresentada, atrasos originais e controlo da terceira carta. O snapshot comum e as falhas históricas estão identificados. A tarefa23 distingue causa de infraestrutura reproduzida (reescrita de RCC mapeado), cronologia compatível e ausência de stack nos primeiros processos; não afirma eliminar qualquer possível falha intermitente do produto.

Spec39–40 permite corrigir “Erros gerais que impeçam jogar ou concluir uma atividade”. As cinco correções de entrada e a estabilização das provas cabem nesse âmbito; não introduzem funcionalidades novas.

Spec43–45 exige validação Windows própria. Os relatórios38807970526 comprovam instalação e203 arranques do candidato dfc26b730, sem alegar gameplay ou atualização para as correções deste lote. As tarefas13/07/08 distinguem corretamente o candidato inicial, o ensaio pessoal Windows11 e a entrega final Windows10.

Verificação repetida: os três testes Node dos dados de memória passaram. Não repeti as sessões Qt extensas, a reprodução de SIGSEGV ou a instalação Windows nesta revisão. Pendências globais deliberadas não foram relistadas como defeitos novos.
