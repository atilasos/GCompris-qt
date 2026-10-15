# Candidato Windows 10 x64 para testes

Este pacote é um candidato de teste, não uma versão aprovada para utilização
letiva. A revisão das vozes, dos conteúdos e dos jogos continua em curso.
A presença de um instalador não dá por concluída a especificação PT-PT.

## Plataforma

Windows 10 de 64 bits, versão 1809 ou posterior. Qt 6.10.2, compilador MSVC2022
x64, DLLs redistribuíveis do MSVC incluídas. O Qt declara esta versão mínima em
[Supported Platforms](https://doc.qt.io/qt-6.10/supported-platforms.html).
O Windows2022 da compilação automática não substitui o Windows10 do professor.

## Construção reproduzível

O workflow `.github/workflows/windows-pt-pt-candidate.yml` executa apenas no fork
`atilasos/GCompris-qt`, em pushes da branch `integration/pt-pt` ou manualmente.
As ações externas são fixadas por SHA. Qt6.10.2 e aqtinstall3.3.0 estão fixados;
OpenSSL vem da revisão fixa de vcpkg declarada no workflow. O submódulo Box2D usa
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
- `activities.txt`, `installed-activities.txt` e logs dos dois arranques.

Os artefactos ficam no separador Actions do fork, associados ao commit de origem.
Não se cria um Release nem se envia código ao projeto original.

## Recursos e implantação

A compilação mantém todas as atividades, com a aplicação de professores separada
desativada (`BUILD_SERVER=OFF`). Usa OGG e o backend FFmpeg, evitando conversões
para MP3 na árvore de fontes. Os recursos completos de imagens, vozes PT, sons e
música são descarregados antes do empacotamento, a partir das URLs e SHA256 fixados
em `tools/windows/assets-lock.json`. Uma alteração no CDN que invalide esses hashes
faz falhar a compilação em vez de distribuir dados não verificados.

A tradução portuguesa é compilada com `lconvert/lrelease` do Qt. O `windeployqt`
atual lê os imports QML das fontes e distribui DLLs e plugins, incluindo FFmpeg,
imagens, TLS e QtGraphs. Esta rota evita a lista manual antiga de plugins do Qt5
presente no empacotamento histórico do projeto. O módulo Box2D é compilado
separadamente para evitar executar `strip` Unix sobre uma DLL MSVC.

A documentação oficial desta implantação é
[Qt for Windows — Deployment](https://doc.qt.io/qt-6.10/windows-deployment.html).

## Verificações automáticas previstas

O script verifica a presença dos RCC de todas as atividades da lista de fontes,
tradução PT, DLLs, plugins e hashes dos recursos. Executa a árvore empacotada com
perfil novo e sem QtSDK no PATH. Uma regra temporária da firewall bloqueia as
ligações de saída do processo GCompris durante esta execução.

Depois, instala o EXE silenciosamente numa pasta de teste e repete a listagem
com outro perfil novo e bloqueio de saída. Ambas as listagens têm de corresponder
exatamente às atividades das fontes. Estes controlos são de implantação e
arranque; não comprovam a conclusão de todos os jogos nem a audição das vozes.

## Teste no Windows10 do professor

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
