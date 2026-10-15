# Corrigir a expectativa do teste de vozes para o locale do sistema

Status: ready-for-agent
Progress: open
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
