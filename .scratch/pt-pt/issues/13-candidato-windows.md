# Preparar um candidato Windows x64 para testes

Status: ready-for-agent
Progress: open
Type: task
Blocked by: 02

## Objetivo

Preparar e executar uma compilação Windows nativa antes da aceitação final de todos
os conteúdos. O professor confirmou Windows 10 x64 e um computador disponível para
testes. Este candidato permite detetar falhas da plataforma enquanto prossegue a
revisão dos recursos; não substitui a tarefa 07 nem a aprovação da tarefa 08.

## Aceitação

- Fixar uma versão Qt compatível com Windows 10 x64 e registar a versão mínima do
  sistema. As notas oficiais do Qt 6.10 indicam Windows 10 1809 ou posterior:
  https://doc.qt.io/qt-6.10/supported-platforms.html
- Compilar a aplicação dos jogos nativamente em Windows, com todas as atividades,
  tradução PT, vozes PT e recursos descarregados antes do empacotamento.
- Produzir o instalador e checksum, com os comandos de compilação registados.
- Verificar a aplicação empacotada, os recursos incluídos e a lista de atividades.
- Disponibilizar um procedimento de teste num perfil novo, sem rede, para o
  Windows 10 do professor. A aprovação da execução real continua pendente até haver
  resultados desse computador.
- Identificar o artefacto como candidato de teste enquanto existirem lacunas de
  conteúdo ou áudio. Não publicar um lançamento final nem marcar a especificação
  concluída por ter produzido um ficheiro EXE.

## Notas

Pode usar GitHub Actions no fork para compilar sem instalar ferramentas de
desenvolvimento no computador da escola. O tracker continua local, sem necessidade
de criar PR. O envio de código deve usar apenas o fork `atilasos/GCompris-qt`.
