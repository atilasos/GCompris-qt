# Restabelecer o equilíbrio de 5 no nível 30

Na balança simples, o nível 30 (dataset 6, oitava linha) dava os pesos
1, 8, 2, 1, 7, 9 e 10, só no prato esquerdo. As somas positivas começam
1, 2, 3, 4, 7: o presente de 5 não podia ser equilibrado. O percurso Qt
completo encontrou a falha; uma repetição do nível pela opção normal
`--start-level 30` confirmou-a.

A correção muda a quarta massa conhecida de 1 para 2 e mantém os quatro
presentes. Assim, 5 = 1 + 2 + 2; 4 = 2 + 2; 7 e 10 têm pesos próprios.
Não altera regras, pontuação ou respostas.

## Prova nativa

`case.qml` é o caso exato executado em red e green, com hash registado nos
dois resultados. Usa apenas rótulos dos pesos e inclinação da agulha para
procurar equilíbrio; não lê o peso oculto ou as respostas do dataset.
Arrasta por eventos mousePress/mouseMove/mouseRelease e responde por teclas
ou cliques reais. O perfil seleciona normalmente o nível inicial, sem preparar
um puzzle resolvido. A ordem dos presentes é aleatória.

- `red/`: a busca observou 4 mais leve e 7 mais pesado, sem soma atingível
  entre ambos. QtTest terminou com uma falha, sem timeout.
- `green/`: quatro puzzles concluídos, incluindo 5, por 36 arrastos; uma
  resposta errada rejeitada. QtTest: duas passagens, zero falhas. Perfil e
  deployment removidos, propriedade privada UID/GID verificada.

Para repetir com um snapshot independente, a partir da raiz do projeto:

```bash
python3 tools/run-native-qml-case.py --resource-snapshot build/scales-snapshot \
  --activity scalesboard --qml-file src/activities/scalesboard/Scalesboard.qml \
  --case .scratch/pt-pt/functional-scales/balance-five/case.qml \
  --output build/balance-five-review --start-level 30 --offline --timeout 240 \
  --result-marker NATIVE_SCALES_RESULT
```

O launcher recompila os recursos da atividade em deployment privado a partir
da fonte desta branch. Não escreve no build principal. O Docker fica sem rede
com o host só para leitura, exceto perfil e saída privados.

## Auditoria dos dados

`tests/functional_scales/check_datasets.py` é uma auditoria separada do solver
UI. Lê as massas e os alvos declarados para enumerar somas/subtrações legais e
recusar qualquer alvo impossível. Não fornece respostas ao caso Qt. Confirma
20 datasets, 142 níveis e 666 alvos atingíveis após a correção, incluindo todos
os quatro alvos da linha alterada. `datasets.json` conserva as contagens.

```bash
python3 tests/functional_scales/check_datasets.py
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover \
  -s tests -p test_scales_dataset_feasibility.py
```

Os dois testes passam; o controlo negativo restaura a massa original numa
cópia temporária e exige a rejeição do alvo 5. Nenhuma fonte é modificada por
esse teste. `unit.log` regista o resultado.

Esta fatia corrige um bloqueio concreto e mantém a tarefa 34 claimed enquanto
os três percursos completos continuam. Não valida Windows, hardware, audição
ou revisão docente.
