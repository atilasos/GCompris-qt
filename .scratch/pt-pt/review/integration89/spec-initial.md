Spec review — tarefa 89
Base: faa44382bf0d3f6d03ce8c0c24f51ed89b076400
Head: e40f2147084129add29f7d16d2ffb0cf0e5e33f7
Diff: git diff faa44382b...e40f21470

1. P2 — Completar a verificação dos ficheiros PNG físicos e da imagem reaberta nas rodas (tests/functional_creation/audit.py:118–119). A aceitação, linhas 24–26, exige «Verificar o conteúdo físico SVG/PNG e o resultado desenhado depois de abrir». O auditor interpreta os SVG das rodas, mas os PNG guardados entram apenas como blobs com identidade; nenhum PNG guardado é descodificado ou comparado com o desenho. Para reabertura das rodas aceita somente `route['reopened']`, um objeto preenchido depois de fechar o diálogo, sem comparar `level-*-saved` e `level-*-opened`. Assim, uma imagem reaberta vazia/errada ou uma pré-visualização PNG errada não é distinguida pelo oráculo. Usar os ficheiros e cenas já preservados para conferir dimensões/conteúdo PNG e equivalência do desenho reaberto, delimitando áreas e eventuais diferenças de renderização justificadas.

2. P2 — Verificar preservação e desfazer/refazer das rodas por imagem (tests/functional_creation/audit.py:112–136). A aceitação, linhas 18–20, pede «desfazer/refazer onde exista e preservar o trabalho nas operações que o prometem». `wheels-levels-v4` envia Ctrl+Z/Ctrl+Y e conserva capturas, mas o auditor não verifica que desfazer retira o desenho e refazer o recupera. Também não compara as cenas antes/depois do cancelamento de saída e de nova imagem capturadas em `wheels-controls-v2`/`sketch-controls-v5`; estes percursos assentam no fecho do diálogo. Acrescentar comparações de píxeis nas áreas de criação aos recibos históricos existentes, sem os reescrever, e negativas específicas para perda de trabalho/refazer ineficaz.

Sem âmbito extra identificado. Diagnósticos/prefixos parciais estão distinguidos adequadamente; Windows, docente e aceitação global continuam pendentes. Revisão apenas de leitura, sem Qt.
