Os dois P2 da revisão43 estão fechados na integração `24b03c952f3aeed6a22e2ffdd02dedefb11f3142`, alteração `03e961d28`.

A retoma compara agora o digest completo das fontes congeladas e a identidade do launcher. PO, IME e CMake pertencem ao digest; recibos antigos sem as identidades necessárias deixam de ser reutilizados automaticamente. Lições inexistentes/zero/negativas e combinações parcialmente inválidas são rejeitadas antes de criar saída ou congelar fontes. Sucesso exige resultados não vazios.

Executei os quatro testes de palavras/corpus: todos passaram, incluindo alterações independentes PO/IME/launcher, retoma sem alterações e oito combinações inválidas nos dois jogos. Executei também a regressão CLI de memória com cinco combinações incompatíveis: passou.

Conferi diretamente entre os dois commits os174 recibos históricos e o summary: bytes inalterados, hashes correspondentes,1740 perguntas e Qt/launcher0. Nenhuma identidade ausente foi inventada nem campanha Qt relançada.

Sem alterações de código/build/provas.
