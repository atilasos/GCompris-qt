# Validar atividades em execução e corrigir falhas que impeçam jogar

Status: ready-for-agent
Progress: claimed
Type: task
Blocked by: 02

## Aceitação

- Manter uma linha por atividade em `../validation.csv`.
- Registar testes de cada modo e diferenças de comportamento entre níveis.
- Cobrir conclusão, respostas certas e erradas, teclado português e navegação.
- Abrir tarefas específicas para falhas e anexar reprodução e evidência da correção.
- Repetir a validação afetada após correções de interface, dados e áudio.
- Não marcar resultados aprovados enquanto houver problemas relevantes abertos nas
  tarefas 03, 04 e 05.

Procedimento: `../validation.md`.


## Progresso

Duas falhas de arranque por ausência de conjuntos predefinidos foram corrigidas
com conteúdo offline, sem ocultar atividades. O rótulo de padrão no desenho
passou a ser traduzível. O verificador tem resultados incrementais e retomada
condicionada a hashes das fontes e da compilação.

Evidência, comandos e limites: `../runtime/review.md`.
Continuam pendentes a execução integrada das 203 atividades, a conclusão dos
níveis/modos, as restantes interações, o áudio e Windows. Não resolver este ticket
com base apenas no teste de arranque.
