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

controls testa navegação, ajuda e menu. configurations percorre dez velocidades
e reinício pelo ciclo real e aguarda a expiração do balão sem alterar duração
ou emitir timeout. Não testa gestos no slider. A reprodução curta keyboard
falha na fonte anterior pela duplicação de algarismos e passa após a correção.

Evidência e limites: .scratch/pt-pt/functional-algebra/README.md.
