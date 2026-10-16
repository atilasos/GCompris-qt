Standards88 — intervalo fixo `e8a5cbf3077585c2f0939115ac507a756b061405...4afe862cb26c3845c97e87e9c034e285001fab63`.

P2, confiança alta — `tests/functional_visual_puzzles/run.py:14` e `capture.py:10`: a guarda de saída nova usa apenas `Path.exists()`. Uma ligação simbólica pendente já ocupa o caminho, mas passa nessa guarda; o runner prepara fontes, cria o log e tenta executar através dessa saída. Um log pendente também só é recusado por `open('x')` depois da preparação. Contraria o contrato «Output and parent log must both be new» do executor e a proteção de saída existente pedida em `issues/88-pormenores-e-pinturas.md`.

Reprodução pura: `PYTHONDONTWRITEBYTECODE=1 python3 /tmp/repro-standards88-dangling-output.py`. Resultado: `existing_symlink=true`, `source_preparation_called=true`, `native_launch_attempted=true`, `new_parent_log_written=true`. Usa mocks de preparação/processo e `/tmp`; não executa Qt. Corrigir as guardas de output/log com `exists() or is_symlink()` antes de qualquer preparação e acrescentar negativos que conservem os links e impeçam preparação/lançamento. É um defeito do executor para futuras observações; não invalida os recibos atuais.

Nenhuma outra violação documentada ou smell Fowler acionável. Consultei code-review, AGENTS/docs de agentes e normas locais; não surgiram CONTRIBUTING/CODING_STANDARDS. A produção altera exclusivamente seis msgstr; o whitespace histórico conhecido foi omitido.

Verificações observadas:

- `git log BASE..TIP --oneline` e `git diff BASE...TIP`.
- Oito testes de `visual_puzzles_audit` passaram normal/`-O`; nove do solver alfa, oito do retangular e três de píxeis passaram.
- Auditor completo e `python3 -O .../adversarial.py --evidence .../capsule` passaram: rejeitam âncora adulterada, alvo coerentemente resselado após validação física e campanha vazia.
- Os quatro blocos recompõem o ZIP literal; 1567 objetos/13536 caminhos conferidos. Comparação Git confirmou 11022 ficheiros nas 14 fases e bytes da cápsula no tip fixo.

São 53 tabuleiros, 367 peças, 35 diferenças e 53 erros reparados. Os retornos Qt/launcher/supervisor e as declarações externas preservam 13 verdes e seis negativos. A composição lexical, o limite das bibliotecas Qt do host e as aprovações humanas/Windows pendentes estão explícitos. Nenhuma prova foi alterada.
