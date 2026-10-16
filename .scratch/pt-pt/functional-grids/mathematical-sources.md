# Regras independentes

A implementação do solucionador usa all-different nas linhas/colunas e nas regiões Sudoku realmente desenhadas. Os números 1–N representam os símbolos visíveis da paleta, sem consultar a solução do motor.

Fontes primárias do editor KenKen para o contrato aritmético, consultadas nesta tarefa:

- [FAQ oficial](https://www.kenkenpuzzle.com/faq): dígitos 1–N, sem repetição na linha/coluna; repetição numa gaiola é possível quando não coincide linha/coluna; rótulo e contorno definem a restrição; subtração em qualquer ordem para duas células.
- [Amostras oficiais sem operadores](https://www.kenkenpuzzle.com/noopsamples): gaiolas com três ou mais células usam adição ou multiplicação.
- [Como jogar](https://discover.kenkenpuzzle.com/how-to-play): ordem irrelevante para subtração/divisão; o solver exige diferença absoluta e quociente inteiro exato em duas células.

As regras são implementadas em módulos puros próprios, verificadas por fixtures e reavaliadas em Python sobre as pistas desenhadas dos recibos. Não se importa o código do motor. Nenhuma afirmação de unicidade editorial é aplicada à geração GCompris; a prova cobre somente as 100 amostras efetivamente apresentadas.
