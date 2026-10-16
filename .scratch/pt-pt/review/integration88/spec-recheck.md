# Recheck Spec — guarda de saídas do lote 88

Delta fixo `4afe862cb26c3845c97e87e9c034e285001fab63...e7b09959a2308076223ba41b6bcddc76022fc1a1`. Apenas leitura e testes puros; sem Qt/build/stress ou alterações de main/provas.

**Correção coerente com o contrato; sem novos achados acionáveis. Confiança alta.**

O ticket88 exige «proteção contra saída existente» e preservação das provas históricas. `tests/functional_visual_puzzles/run.py` passa a recusar `exists()` ou `is_symlink()` tanto no destino como no log associado, antes de verificar o caso, preparar fontes ou abrir ficheiros. `capture.py` faz a mesma recusa para o destino antes de qualquer lançamento. Assim, uma ligação pendente não é confundida com um caminho novo.

Executei os dois testes/sete subcasos em Python normal e `-O`; todos passaram. As fixtures cobrem saída pendente, log pendente no runner, ficheiro e diretório, com mocks que falham se preparação ou processos forem chamados. Confirmam retorno2 e preservação do link/destino, sentinel e bytes anteriores. O vermelho histórico conserva as três falhas anteriores, sem lançamento Qt.

O diff limita-se às guardas futuras, regressões/documentação e remoção de uma linha vazia em `svg.py`. Nenhum produto, caso QML, algoritmo de píxeis, cápsula, fonte congelada ou dos19 recibos históricos é alterado. A documentação distingue a correção do executor das provas de jogabilidade já concluídas; não pretende nova campanha ou aprovação adicional.

A spec35 exige «Cada conclusão é sustentada por evidência». Como a mudança apenas fecha a fronteira de saídas antes do lançamento e não muda os jogos/oráculos/casos executados, não repetir os53 tabuleiros é uma delimitação adequada. Mantêm-se as conclusões e limites da revisão inicial: auditoria física portátil não equivale a runtime Qt inteiro selado, e Windows, equipamento, audição, revisão docente, estabilidade83 e aceitação global continuam pendentes. Sem regressão de âmbito.
