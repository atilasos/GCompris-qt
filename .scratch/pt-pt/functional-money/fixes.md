# Correções reproduzidas no dinheiro

A tarefa 60 continua em curso. Estes casos Linux com Qt real não aprovam Windows, dispositivos, audição ou pedagogia.

## Teclado no modo automático

`automatic-keyboard-red` usa as fontes Git `0df3a261b8ba60ee2a518a2f1ff80382da34861f`. Depois de selecionar uma moeda que difere do preço visível, Tab e Espaço não a removiam. `automatic-keyboard-green` usa `29041be632ab3f86c844b554239c19f864470a9e`: o mesmo caso remove a moeda. O recibo confirma o mesmo SHA-256 de caso. A validação automática deixava `buttonsBlocked` ativo mesmo quando o pagamento ainda não era exato. A correção permite continuar e desfazer o pagamento incompleto.

## Cliques durante o aviso

`manual-feedback-red` usa as fontes `29041be632ab3f86c844b554239c19f864470a9e`. Depois de confirmar um pagamento errado com OK, o aviso aparece e outro clique aumenta a resposta de uma para duas moedas. `manual-feedback-green` usa `8d9b050078c7d6d40a8e962651bee493cae8ab25`. O mesmo caso mantém uma moeda durante o aviso. A área de toque agora respeita a guarda de controlos já usada pelo teclado e pelo botão OK. Não foram alterados relógios nem animações.

## Compra sem pagamento possível

`reachability-red` usa as fontes `29041be632ab3f86c844b554239c19f864470a9e`. A navegação normal chega ao nível 20 de Dinheiro com cêntimos, conjunto 3. Os preços apresentados foram 4,16 €, 6,33 € e 7,90 €, total de 18,39 €. Sem usar as notas de 20 € ou 50 €, a carteira só tinha 17,09 €. O oráculo de subconjuntos das imagens visíveis não encontra pagamento.

A correção acrescenta uma nota de 10 € à carteira desse nível. `reachability-green`, fontes `8d9b050078c7d6d40a8e962651bee493cae8ab25`, conclui o mesmo caso com 12 compras naturais, pagamentos exatos, Bonus e navegação de regresso. O auditor separado `tests/functional_money/inventory.py` demonstra atingibilidade de todos os montantes de um envelope conservador para cada um dos 103 níveis. O solver da interface usa apenas preços e imagens efetivamente apresentados.

Os três pares usam snapshots privados sem symlinks mutáveis, rede Docker desativada, ficheiros privados com UID/GID local e saída normal do processo Qt. Os vermelhos são falhas de asserção esperadas, sem indução de falhas de processo. `phases/` conserva os manifestos de fontes e de snapshot, mais os mapas de ficheiros realmente expostos por QResource nos cinco RCC relevantes de cada fase.
