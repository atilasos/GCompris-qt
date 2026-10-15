# Trabalho PT-PT

O âmbito aprovado está em [spec.md](spec.md). O estado do trabalho está em
[map.md](map.md) e nas tarefas de `issues/`.

Para regenerar apenas os relatórios estáticos, executa na raiz do repositório:

```bash
python3 tools/audit-pt-pt.py --output .scratch/pt-pt/reports
```

Para obter código de saída 1 quando existirem lacunas conhecidas nos catálogos ou
JSON PT inválido, acrescenta `--check`. Um resultado 0 não certifica a qualidade
linguística, os recursos partilhados, o áudio ou a execução dos jogos.

Para verificar a ferramenta:

```bash
python3 -m unittest discover -s tests -p 'test_audit_pt_pt.py'
```

A ferramenta usa apenas a biblioteca padrão de Python 3 e não altera traduções,
dados dos jogos ou resultados de validação. `reports/` contém saídas geradas.
`validation.csv` e `validation/` contêm resultados de execução mantidos à parte.

A compilação e as verificações locais estão descritas em [build-linux.md](build-linux.md).
O teste de arranque reutilizável é `tools/smoke-activity.py`. Este teste deteta
falhas QML ao iniciar atividades; não certifica níveis, áudio ou qualidade linguística.

Para verificar os conteúdos e as respostas das duas atividades de gramática:

```bash
node --test tests/grammar_pt_pt.test.mjs
```

O teste usa o JavaScript original do jogo. A revisão linguística dos novos dados
está descrita em [grammar-review.md](grammar-review.md).
