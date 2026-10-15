P2 da revisão34 fechado na integração `a412d4a0a7329ee33c68872c231ce04050978a90`, alteração `6746988ce`.

O wrapper reclama atomicamente uma saída nova antes de preparar o caso. Diretórios/ficheiros existentes são recusados; o caso gerado tem temporário exclusivo por invocação e só é copiado para a saída reclamada.

Executei os dois testes CLI: passaram as recusas de arquivo/diretório vazio/ficheiro, preservação dos bytes, ausência de preparação e execuções novas com retorno0/2, temporários distintos e limpeza. Verifiquei também por subprocesso uma saída symlink para arquivo: código2, ligação e bytes do destino preservados, launcher não iniciado.

Comparei diretamente os nove resultados/casos e summary históricos entre os commits anterior e integrado: bytes inalterados e SHA256 correspondentes ao índice. Não repeti os666 puzzles, não alterei código/build/provas.
