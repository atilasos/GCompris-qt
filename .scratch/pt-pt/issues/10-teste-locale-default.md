# Corrigir a expectativa do teste de vozes para o locale do sistema

Status: ready-for-agent
Progress: resolved
Type: task

## Reprodução

No ambiente atual, com locale do sistema `C`:

```bash
QT_QPA_PLATFORM=offscreen ctest --test-dir build/pt-pt --output-on-failure
```

Sete suites passam. Em `CoreApplicationInfoTest`, o caso `getVoicesLocaleTest(default)`
espera `QLocale::system().name()`, ou seja, `C`. A aplicação devolve `en_US`, conforme
o fallback explícito de `ApplicationInfo::getVoicesLocale`.

Com `LC_ALL=en_US.UTF-8`, as oito suites passam. Os casos explícitos `pt_PT` → `pt`
e `pt_BR` → `pt_BR` passam também no ambiente original.

## Aceitação

- Verificar a expectativa correta para a seleção de vozes do sistema, incluindo
  normalização para um idioma com vozes e fallback de `C`.
- Corrigir o teste sem alterar o comportamento de produção apenas para satisfazer
  a expectativa errada.
- Executar os testes em `C`, `pt_PT` e `en_US`, sem ocultar falhas.

Esta falha do teste não impediu a compilação nem o arranque dos jogos.


## Answer

Corrigida a expectativa do teste, sem alterações ao código de produção.
A expectativa anterior falhava em `C` e também em `pt_PT`: o primeiro devolve
`en_US` por fallback e o segundo é normalizado para o conjunto de vozes `pt`.

O teste usa agora processos separados com uma tabela independente de resultados
para `C`, `pt_PT`, `en_US`, `en_GB`, `pt_BR` e `fr_FR`. Também confirma o locale
que o Qt efetivamente leu, evitando que um fixture ignorado conte como sucesso.
Foi removida a alteração global desnecessária de `QLocale::setDefault`, que não
alterava `QLocale::system` e podia ficar por restaurar após uma asserção falhada.

As oito suites C++ passaram em `C`, `pt_PT.UTF-8` e `en_US.UTF-8`, sem skips no
teste de ApplicationInfo. Os processos de fixtures POSIX são compilados apenas
em Unix; os testes de locale explícito continuam disponíveis em Windows.
O teste Windows do produto mantém-se na tarefa 07.

Construção privada, preparação dos recursos e evidência em
`../locale-validation/README.md`. A primeira execução do conjunto privado
identificou falta de RCC de teste; após disponibilizar três RCC existentes por
ligações apenas para leitura, todas as suites passaram. Não foi alterado o build
partilhado.
