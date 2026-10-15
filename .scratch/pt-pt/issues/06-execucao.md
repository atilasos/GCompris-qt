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
O arranque integrado das 203 atividades passou com perfis novos e Docker sem
rede. As tarefas 16/17 acrescentaram conclusão interativa de todos os níveis dos
quatro jogos abrangidos. A tarefa 15 acrescentou os quatro jogos de letras e
teclado (74 percursos). O segundo rastreio de arranque passou com as 1610 vozes
e a correção de seleção de recursos da tarefa 18. Continuam pendentes os restantes níveis/modos e
interações e Windows. A aprovação docente das 32 gravações novas foi registada
na tarefa35; isso não substitui a reprodução em cada plataforma. Não resolver este ticket
com base apenas no teste de arranque.

As tarefas19/20 acrescentam conclusão dos dois jogos de leitura e palavras em
queda. A tarefa21 concluiu os percursos dos três jogos de memória abrangidos. Os encerramentos
durante testes foram encaminhados para diagnóstico separado; não contam como
aprovados. A tarefa22 já reproduziu e corrigiu eventos duplicados em 14 motores,
com provas específicas; isto não conclui os jogos completos. A tarefa24 trata
identificadores de categorias mostrados em inglês no rodapé da ajuda.

A matriz liga atualmente evidência funcional de 48 atividades, mantendo os
critérios globais pending. As tarefas34/38 continuam em campanhas completas; a tarefa37 concluiu os
43 percursos das cinco variantes restantes de memória;
a tarefa39 concluiu a exploração do primeiro teclado. A tarefa40 corrigiu
apenas os metadados de níveis do Solitário, sem validar os seus puzzles.
