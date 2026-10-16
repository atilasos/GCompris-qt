# Preparar compilação e testes locais em Linux

Status: ready-for-agent
Progress: resolved
Type: task

## Aceitação

- Qt 6 e dependências de desenvolvimento instalados; versão registada.
- Fontes de qml-box2d preparadas com origem e revisão identificadas.
- Compilação com `BUILD_TESTING=ON` e execução dos testes de infraestrutura.
- Aplicação iniciada em PT-PT, com logs e comandos reproduzíveis.

## Answer

Dependências instaladas pelo utilizador. Configuração e compilação concluídas com
Qt 6.10.2 e `BUILD_SERVER=OFF`, mantendo todas as 203 atividades. O alvo `getAssets`
descarregou os recursos e as vozes PT. As oito suites C++ passaram com locale
`en_US.UTF-8`; a divergência do teste no locale `C` está registada na tarefa 10.

A aplicação arrancou em PT-PT. A execução real detetou uma incompatibilidade QML
no seletor de cores, corrigida e verificada na tarefa 09. O painel da caneta do
compasso foi aberto numa janela real e capturado em português.

Comandos, versões e evidências: `../build-linux.md`.
