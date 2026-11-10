# Testes nativos das operações

Criar um snapshot com tools/native_qml_resources.py ou reutilizar um snapshot
selado produzido pelo launcher. Requer Qt6 rcc/QtTest, Docker e a imagem Alpine
já instalada. Nenhum recurso do build é reescrito.

Para cada uma de algebra_plus, algebra_minus, algebra_by e algebra_div:

```bash
python3 tests/functional_algebra/run.py --activity algebra_plus \
  --resource-snapshot /caminho/snapshot --output /novo/resultado
```

O runner gera uma referência determinística com Fraction e injeta gameplay.qml
num RCC privado. A referência cobre os operandos legais e verifica quatro
exemplos literais. O teste observa operações/resultado/pontuação e usa cliques
e teclas, incluindo Backspace, erros, Bonus e conclusão de todos os níveis.

Para controls.qml, configurations.qml ou keyboard.qml:

```bash
python3 tools/run-native-qml-case.py --source-root . \
  --resource-snapshot /caminho/snapshot --activity algebra_plus \
  --qml-file src/activities/algebra_by/Algebra.qml \
  --case tests/functional_algebra/configurations.qml \
  --output /novo/resultado --timeout 60 \
  --result-marker NATIVE_ALGEBRA_RESULT --offline
```

controls testa navegação, ajuda e menu. configurations liga o limite de tempo
(o runner arranca sem configuração guardada, logo sem limite), percorre dez
velocidades e reinício pelo ciclo real e aguarda a expiração do balão sem
alterar duração ou emitir timeout. Não testa gestos no slider.

Limite de tempo (opção «Sem limite de tempo», chave `timeLimit: "off"|"on"`),
com o mesmo comando e `--timeout 240`:

- timelimit-default: sem configuração guardada não há limite; uma resposta
  certa é aceite após 22,5 s (mais do que os 21 s antigos da velocidade 5) na
  primeira pergunta, depois de uma resposta certa, com redimensionamento da
  janela e depois de uma resposta errada; o balão fica escondido e em repouso.
- timelimit-dialog: liga e desliga pelo diálogo real («Gravar»), confirma a
  expiração com limite na velocidade máxima do slider e a ausência dela na
  mesma janela sem limite, e a persistência ao reabrir o diálogo.
- timelimit-legacy: configuração antiga só com `speedSetting` mantém o limite
  e `balloon.duration == 100000 / speed`. Precisa de perfil limpo.

Os `ActivityConfig.qml` de algebra_plus/minus/div vêm do snapshot: recompile
os alvos `rcc_algebra_*` e crie um snapshot novo depois de os alterar. A reprodução curta keyboard
falha na fonte anterior pela duplicação de algarismos e passa após a correção.

Evidência e limites: .scratch/pt-pt/functional-algebra/README.md.
