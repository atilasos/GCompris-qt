# Preparar um candidato Windows x64 para testes

Status: ready-for-agent
Progress: claimed
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

## Comments — implementação da construção automática

Preparados o workflow nativo Windows2022/MSVC x64 e os scripts de implantação em
`tools/windows/`. Qt6.10.2 exige Windows10 1809+. As ações, Qt, aqtinstall, vcpkg e
NSIS têm revisões/versões fixadas; os oito ficheiros dos recursos offline atuais
(quatro RCC e quatro Contents, cerca de853MB) têm hashes SHA256 fixados.

Verificação local: três testes Python passaram, incluindo rejeição de recurso
alterado; download real de Contents passou o hash; actionlint1.7.7 aprovou o
workflow e o parser PowerShell7.4.6 aceitou o script. Estes resultados não são uma
compilação Windows. O workflow precisa agora de ser enviado para a branch de
integração do fork para gerar o candidato e executar os controlos nativos.

O script instalará o EXE gerado numa pasta separada e verificará a listagem das
atividades com perfil novo e bloqueio de saída na firewall, além da árvore
portátil. Os resultados e SHA256 serão guardados no artefacto Actions.
Procedimento e limites: `../windows-candidate.md`.

A tarefa permanece `claimed` até existir resultado real da compilação, instalador,
checksum e controlos nativos. A execução no Windows10 do professor continua
pendente e não pode ser inferida do runner WindowsServer2022.


Correção antes do primeiro envio: a rota Windows passa a compilar a tradução com
`compile-portuguese.py`, indicando explicitamente `pt_PT` ao lconvert. Um teste
com o QTranslator real reproduziu o defeito sem essa opção (0/1/2 devolviam todos
singular) e passou depois da correção (0 maçãs, 1 maçã, 2 maçãs). Os quatro testes
Windows-candidate passaram em Linux; o teste QTranslator é específico da
instalação Qt Linux e não se faz passar por uma execução Windows. A compilação
Windows usa exatamente o mesmo helper de conversão.


Primeira execução Windows real: Actions38797896819 falhou na seleção dos pacotes
Qt, antes de compilar: `qtsvg` não é um módulo opcional da distribuição6.10.2
MSVC2022. Removido esse nome de `--modules`; o QtSvg faz parte dos pacotes-base
selecionados por aqt, e o `find_package(Qt6 ... Svg)` do projeto verificará a sua
presença na configuração seguinte. O erro externo não foi tratado como sucesso.


Seguimento de áudio: o pipeline passa a executar o target Qt
`pt_audio_rcc_inventory` e `complete_voices.py` depois do download fixado. Mantém
intacto o RCC original e inclui o RCC standard com 1610 gravações, mais manifestos
e notas. O verificador mantém todos os hashes originais exceto o índice de vozes
atualizado, que é verificado juntamente com o RCC novo pelo manifesto de conclusão.
Teste de regressão rejeita corrupção tanto do original como do RCC completado.
A revisão final da pronúncia permanece explícita. O script NSIS também foi
compilado localmente por NSIS3.10 com um payload mínimo: comprova a sintaxe do
instalador/desinstalador, não a execução no Windows.


Segundo ensaio real, Actions38798167757: compilação MSVC da aplicação/Box2D e dos
RCC concluída, catálogo PT com 3869 mensagens compilado e os oito ficheiros offline
descarregados com hashes corretos. A implantação falhou porque o windeployqt
real da versão6.10.2 não aceita `--include-soft-plugins`. A opção foi removida;
as restantes opções foram confirmadas no código Qt tagv6.10.2, e o próximo
ensaio guardará também o `--help` real da ferramenta. Ainda não há instalador
aprovado nem prova de execução Windows10.

As correções da revisão estão descritas em `../review-fixes.md`. O cache do SDK
é guardado imediatamente depois da preparação, antes das verificações de
implantação; uma falha posterior deixará de obrigar a repetir essa preparação.
A tarefa06 continua em curso: o workflow mantém oito arranques na árvore
preparada e exige o arranque sequencial das 203 atividades na árvore instalada.
Isto não valida interativamente todos os jogos nem a conclusão dos níveis.
A extensão `--activities-file` foi testada contra o manifesto real (203 nomes
únicos, incluindo maiúsculas e hífens), rejeição de nomes inválidos/duplicados e
um executável fixture que comprova a ordem e a rejeição de listas divergentes.
A prova dos 203 arranques Windows exige um novo ensaio CI após integração.

## Falha real de instalação e fronteira NSIS

Actions 38805685864 confirmou os oito arranques nativos da árvore preparada
(com marcadores, RCC PT completado e sem erros QML) e a lista de 203 atividades.
Gerou um instalador de 825756403 bytes, mas a instalação silenciosa não colocou
o executável no destino esperado: NSIS elimina barras `/` do argumento `/D=`
(função `validate_filename`, código oficial v3.11, `Source/exehead/util.c`).

O helper `install-candidate.ps1` cria o destino e obtém o `FullName` nativo antes
de passar `/D=` como último argumento sem aspas adicionais; também exige
`bin/GCompris.exe` após exit0. O teste PowerShell cobre caminho com espaços e
`/.`, exit não zero e sucesso sem executável. Antes do build principal o CI
compila e executa um NSIS mínimo real, usando o mesmo helper, e verifica os
bytes sentinela no destino canónico. A execução desse teste PE e a validação
dos 203 arranques instalados aguardam o próximo CI; a presença do primeiro EXE
no artefacto falhado ainda não valida a instalação.
