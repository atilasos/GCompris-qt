# Candidato Windows 10 x64 para testes

Este pacote é um candidato de teste, não uma versão aprovada para utilização
letiva. A revisão das vozes, dos conteúdos e dos jogos continua em curso.
A presença de um instalador não dá por concluída a especificação PT-PT.

## Plataforma

Windows 10 de 64 bits, versão 1809 ou posterior. Qt 6.10.2, compilador MSVC2022
x64, DLLs redistribuíveis do MSVC incluídas. O Qt declara esta versão mínima em
[Supported Platforms](https://doc.qt.io/qt-6.10/supported-platforms.html).
O Windows2022 da compilação automática não substitui o Windows10 da escola.
O computador pessoal disponível para o primeiro ensaio usa Windows11 25H2,
compilação 26300.9711. Esse ensaio complementa a validação obrigatória nos
computadores Windows10 x64 da escola.

## Construção reproduzível

O workflow `.github/workflows/windows-pt-pt-candidate.yml` executa apenas no fork
`atilasos/GCompris-qt`, em pushes da branch `integration/pt-pt` ou manualmente.
As ações externas são fixadas por SHA. Qt6.10.2 e aqtinstall3.3.0 estão fixados;
OpenSSL vem da revisão fixa de vcpkg declarada no workflow. O SDK Qt e o prefixo
OpenSSL instalado têm cache separado, com chave que inclui runner, compilador,
versão Qt, hash de `qt-modules.txt` e revisão vcpkg. O cache é guardado antes dos
testes de implantação para sobreviver a uma falha posterior, e não inclui fontes
nem candidatos. O submódulo Box2D usa
sempre a revisão registada no Git. O NSIS está fixado na versão3.11.0.
O runner Windows2022 e o compilador são mantidos pelo GitHub e podem receber
atualizações: não se afirma reprodução binária bit a bit.

Depois de instalar essas ferramentas, numa shell PowerShell7 com ambiente
MSVC2022 x64:

```powershell
./tools/windows/build-candidate.ps1 -QtRoot C:/Qt/6.10.2/msvc2022_64 -OpenSSLRoot C:/candidate-vcpkg/installed/x64-windows
```

O script regista os comandos em `build/windows-candidate/build.log` e gera:

- `artifacts/GCompris-PT-PT-Windows-x64-candidate.exe`: instalador NSIS.
- `artifacts/GCompris-PT-PT-Windows-x64-portable.zip`: mesma árvore portátil.
- `artifacts/SHA256SUMS.txt`: SHA256 dos dois ficheiros.
- `package-check.json` e `installer-check.json`: inventário e listagem nativa.
- `staged/`: listagem e logs da amostra de oito atividades.
- `installed/`: listagem e logs das 203 atividades do manifesto; ambas as árvores
  incluem `startup-check.json`.

Os artefactos ficam no separador Actions do fork, associados ao commit de origem.
Não se cria um Release nem se envia código ao projeto original.

## Recursos e implantação

A compilação mantém todas as atividades, com a aplicação de professores separada
desativada (`BUILD_SERVER=OFF`). Usa OGG e o backend FFmpeg, evitando conversões
para MP3 na árvore de fontes. Os recursos completos de imagens, vozes PT, sons e
música são descarregados antes do empacotamento, a partir das URLs e SHA256 fixados
em `tools/windows/assets-lock.json`. Uma alteração no CDN que invalide esses hashes
faz falhar a compilação em vez de distribuir dados não verificados.

Após esse download, o utilitário Qt `pt_audio_rcc_inventory` e o script
`complete_voices.py` recompõem o pacote standard com as 1578 gravações originais e
as 32 adições aprovadas. O RCC original permanece incluído e verificado pelo hash
fixo. O novo RCC e o índice `Contents` são verificados pelos hashes do
`completion.json`, que referencia também a identidade do original. O pacote
inclui as notas de origem/licença dessas adições. A revisão final da pronúncia
continua a ser registada pelo professor.

A tradução portuguesa é compilada com `lconvert/lrelease` do Qt. O `windeployqt`
atual lê os imports QML das fontes e distribui DLLs e plugins, incluindo FFmpeg,
imagens, TLS e QtGraphs. Esta rota evita a lista manual antiga de plugins do Qt5
presente no empacotamento histórico do projeto. O módulo Box2D é compilado
separadamente para evitar executar `strip` Unix sobre uma DLL MSVC.

A documentação oficial desta implantação é
[Qt for Windows — Deployment](https://doc.qt.io/qt-6.10/windows-deployment.html).

## Verificações automáticas previstas

O script verifica a presença dos RCC de todas as atividades da lista de fontes,
tradução PT, DLLs, plugins e hashes dos recursos. Usa uma função única para testar
a árvore empacotada e a instalada, com uma regra temporária da firewall a bloquear
saídas do processo. Todas as variáveis Qt/QML/QSG e PATH alteradas são restauradas
em `finally`, juntamente com a remoção dessa regra.

Antes da primeira execução, exige que não existam dados GCompris nas Known Folders
reais do Windows. O Qt consulta essas pastas através de APIs Windows; mudar apenas
APPDATA/LOCALAPPDATA não cria um perfil novo. Se existirem dados, o script recusa
o teste e pede uma conta dedicada, preservando os ficheiros existentes. Os testes
da instalação usam a mesma conta CI inicialmente limpa e processos independentes;
não são apresentados como um segundo utilizador Windows novo.

A árvore preparada abre uma amostra de oito atividades: gramática (duas),
letras, letras cadentes, teclado, escolhas múltiplas, cronologia e criação de
frações. A árvore instalada abre sequencialmente as 203 atividades de
`src/activities/activities.txt`, exigindo nomes únicos e correspondência exata
com a lista devolvida pelo executável. Cada processo tem de permanecer ativo
durante seis segundos, registar o lançamento da atividade e o RCC PT completado,
sem erros QML ou erros de imagens detetados. O percurso instalado demora cerca
de 21 minutos e usa a mesma conta Windows, sem processos concorrentes.

Estes controlos comprovam implantação e arranque. Não comprovam a conclusão dos
níveis, todos os modos, a reprodução audível num dispositivo Windows ou a revisão
pedagógica. A audição e a matriz funcional continuam pendentes no Windows10 real.

## Primeiro teste no Windows11 pessoal e confirmação no Windows10 da escola

1. Transferir o candidato, `SHA256SUMS.txt` e os logs do mesmo artefacto Actions.
2. Verificar o EXE com `Get-FileHash .\GCompris-PT-PT-Windows-x64-candidate.exe -Algorithm SHA256`.
3. Usar um utilizador Windows novo, para não aproveitar recursos de testes antigos.
4. Desligar Wi-Fi e Ethernet antes de instalar. O instalador já contém os recursos;
   não precisa de descarregar dependências. Instalar com permissões administrativas.
5. Abrir o atalho «GCompris PT Teste», que seleciona `pt_PT`. Confirmar menus,
   instruções e ajuda; abrir as duas atividades de gramática, letras, teclado,
   leitura, vocabulário e atividades que usam gráficos/som.
6. Jogar exemplos com respostas certas e erradas, `ç`, caracteres acentuados e
   maiúsculas. Testar as vozes com o áudio do computador ativo. Registar a versão
   indicada por `winver`, o commit de `source-commit.txt` e os resultados.
7. Executar a matriz completa da tarefa07; guardar os erros/capturas e a atividade,
   nível, ação e resultado esperado. A revisão linguística/pedagógica é tarefa08.
8. Testar também o atalho «modo seguro» se houver problemas gráficos; registar
   qual o modo necessário e o modelo de placa gráfica.

As lacunas de áudio e conteúdo já identificadas permanecem pendentes mesmo que o
programa abra e todas as atividades apareçam na lista. Não aprovar a instalação
para as crianças antes de fechar essas lacunas e a verificação no Windows10.
