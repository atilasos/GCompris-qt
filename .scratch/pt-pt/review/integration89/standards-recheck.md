# Standards89 — recheck

Base: `e480214061ae38bb8b99586ca7535cfeef20426e`.
Head: `e9a7a84502661d261c121638ac580a2337486e3b`.
Fix: `99c1cebe479ca7824d002036286c292bf6c17a84`.
Diff conferido: `git diff e48021406...e9a7a8450`.
Commits: `99c1cebe4`, merge `e9a7a8450`.

Aplicadas as normas documentadas já lidas na revisão inicial (AGENTS, HACKING,
README e docs/agents) e todas as12 heurísticas da baseline code-review, como
julgamentos e com precedência das normas locais. Âmbito exclusivamente Standards;
a revisão Spec é separada.

**P3 anterior encerrado.** O pipeline duplicado de compilação/exportação RCC
passou para `tests/functional_creation/rcc_export.py:6–13`.
`run.py`, `capture_resources.py` e `seal.py` chamam as mesmas funções,
com fonte C++, binário, RCC e destino explícitos. Flags de compilação e leitura
JSON têm um único ponto de manutenção; erros de subprocesso propagam-se.
É uma extração pequena e justificada pelo achado, sem generalidade especulativa
ou delegação vazia: concentra configuração do compilador e validação da resposta
externa. Os testes exercitam a fronteira subprocesso sem executar Qt.

As guardas novas verificam o argumento original com `is_symlink()`/`exists()`
antes de o resolver e antes de ler fontes; `seal()` também protege chamadas
diretas. Os casos CLI cobrem link pendente, ficheiro e diretório existentes,
conservando link/alvo/bytes. Não encontrei violação documentada ou smell
acionável nessa alteração.

O suplemento visual mantém responsabilidades reconhecíveis: carregamento da
cápsula, operações de raster/vetores e verificações de fluxos. Conserva âncoras
literais e separa tolerâncias e diagnósticos de novas conclusões nativas. A
comparação Git confirma que `.scratch/pt-pt/functional-creation/` histórica não
foi modificada pelo fix; não há diff novo de produção, PO ou launcher partilhado.
Não interpreto os testes28+5 documentados como uma execução integral de31.

**Resultado: zero achados Standards abertos; zero violações duras.**
Sem nova execução de testes, Qt, build, push ou alteração de código/provas/main.
Árvores e renders90 preservados.
