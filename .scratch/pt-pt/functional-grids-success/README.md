# Suplemento 87 — menu após sucesso

O ticket original exigia menu, sem dizer literalmente «após sucesso». A revisão Spec recebeu esse mandato complementar; a lacuna não demonstra defeito no produto nem invalida as 168 conclusões. A cápsula original e os seus 19 recibos permanecem intactos.

Dois casos curtos completam naturalmente o nível 2 de Sudoku/conjunto 1 (cinco grelhas 3×3) e o único nível Calcudoku/conjunto 1 (20 grelhas 3×3). O solver independente e as entradas reais são os mesmos do lote original: pistas/desenho, sem soluções ocultas, escrita de progresso ou alteração de temporizadores. Cada caso espera a animação do Score e o Bonus flower_good natural, espera a continuação e estabilidade dos controlos e clica no botão real de início. Verifica profundidade 1, menu visível e estabilidade após mais 1900 ms, conservando screenshot. O ajuste startingActivity vazio é a configuração do launcher para permitir menu normal, não escrita de progresso.

São 25 conclusões repetidas, dois Bonus naturais e dois regressos ao menu após sucesso; não ampliam a cobertura única de 68 grelhas fixas/100 amostras do lote original. A geração Calcudoku continua uma amostragem finita, sem exaustão/garantia de unicidade.

Reutilizam-se as fontes finais d740510aa8a87611d28e4776e64c8345fc4b2a64 congeladas e verificadas antes das campanhas e o snapshot privado grids-help-fixed de 269 ficheiros. Não se lê nem compila o build principal. Os casos exatos foram materializados antes dos lançamentos. O supervisor/launcher congelado conserva deployments desde o primeiro run, Docker sem rede, host readonly, UID/GID 1000 e escrita apenas em perfil/saída privados. Ambos os RCC/QM efetivos e extrações QResource/QM→TS, fontes, casos, imagens e retornos são fisicamente arquivados num suplemento novo com âncora SHA literal externa. Todos os retornos tool são registados após wait e distinguem-se dos recibos nativos.

Executar `python3 tests/functional_grids_success/audit.py` e `python3 -m unittest discover -s tests/functional_grids_success`. Copiar apenas a cápsula, audit.py e oracle.py permite auditar sem Git/Qt/checkout. Testes recusam bytes físicos adulterados, resselagem coerente e -O. O auditor original continua obrigatório para a prova original; este suplemento não o substitui. O teste original de saída existente mantém-se verde e o runner original recusa antes de escrever estados.

Sem alterações de produto, áudio ou novas aprovações. Windows, hardware, audição, docente e estabilidade83 continuam pendentes.
