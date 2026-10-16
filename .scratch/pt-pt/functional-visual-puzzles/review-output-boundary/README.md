# Proteção das saídas ocupadas

A revisão Standards encontrou que exists() não deteta uma ligação simbólica pendente. O executor aceitava essa saída e iniciava preparação/lançamento; a reprodução do revisor usa mocks e não executa Qt. Os 19 casos preservados usaram caminhos novos e não são invalidados.

Dois testes com sete subcasos cobrem saída pendente, log pendente, ficheiro e diretório ocupados. Antes da correção, três subcasos falhavam porque preparação/lançamento eram chamados. Depois da guarda adicional is_symlink(), todos passam em Python normal e -O. Comprovam rejeição anterior à preparação e ausência de escrita/alteração dos caminhos.

Estes são testes puros do executor futuro. Não houve nova execução de jogo ou alteração de produto. As fontes históricas, recibos e a âncora da cápsula original permanecem intactos. A linha vazia adicional de svg.py também foi removida.
