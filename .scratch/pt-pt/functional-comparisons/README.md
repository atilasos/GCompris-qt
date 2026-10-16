# Comparar números e descobrir os vizinhos

A tarefa 69 seleciona nove casos: oito positivos e um vermelho esperado.
O fecho das campanhas e a publicação dos hashes ainda aguardam o commit de
captura. Pilotos e diagnósticos ficam separados e não contam como conclusão.

## Percursos selecionados

| Caso | Âmbito |
| --- | --- |
| comparator-complete | 26 níveis, 130 perguntas, 650 comparações |
| adjacent-automatic-complete | 25 níveis, 125 perguntas, validação automática |
| adjacent-manual-complete-rerun | 25 níveis, 125 perguntas, OK ou Enter |
| comparator-controls, adjacent-controls | Reinício, escolhas persistidas, navegação, ajuda, foco e menu |
| comparator-resources, adjacent_numbers-resources | Cópia dos QML/JS/SVG/WAV e carregamento dos SVG |
| adjacent-contract-red, adjacent-contract-green2 | Mesmo caso Qt antes/depois da publicação dos níveis |

O oráculo do comparador usa `Decimal` nos rótulos portugueses realmente
visíveis, incluindo vírgula decimal e sinais menor/igual/maior. O caso Qt usa
outra estratégia, comparação dos algarismos normalizados. O auditor confere
independentemente as 650 respostas, intervalos e precisão de cada nível.
Os dados originais do comparador não incluem números negativos.

Nos vizinhos, o auditor recebe apenas os números mostrados e os pontos de
interrogação, deduz a cadeia de passo um e confere todos os termos e espaços
em falta. Os limites do dataset aplicam-se ao início da cadeia. Há dados
negativos. Os recibos guardam a instrução portuguesa e os modos automático
ou manual; não se lê o valor oculto dos espaços como resposta.

Os casos Qt usam escolhas, teclas e arrastos reais. Cada pergunta recebe
uma resposta errada e depois a correção, com Score/Bonus e transições
naturais. Não se atribui progresso nem se encurtam relógios. As perguntas
aleatórias exercitadas não esgotam todas as combinações.

## Identidades e auditoria

A fonte final é `e38441ab1e30fe543db96b35a913857f70153dc9`.
`archive/` contém 262 ficheiros Git, com catálogo, casos gerados,
launcher/supervisor, manifesto do snapshot e recursos originais. Conserva
também o QML vermelho de `d76b8408a`. O comparador final é byte a byte igual
à sua fonte em `7e334d5ee`. SHA-256 do manifesto de fontes:
`fcb173f1fe9ebcb9902f2b52577b53e83659ef389e92f71ebee5a2a4e88645a4`.

`capture.json` ligará os nove diretórios selecionados a blobs de um commit
Git imutável. O auditor fixa o SHA desse manifesto, além do SHA de fontes.
Assim, recalcular um manifesto depois de alterar PO, QML, caso, status,
resposta ou imagem não cria uma prova válida. Cada status pós-espera liga a
saída externa ao SHA do recibo Qt. O vermelho deve ter retorno externo 1,
Qt 0 e uma asserção falhada; os oito positivos devem ter ambos os retornos 0.

As 76 capturas são de fim de nível/Bonus. Os seus bytes e formato de imagem
são verificados; não são 380 capturas de perguntas nem se afirma OCR ou
contagem de píxeis dos rótulos. As respostas independentes são conferidas
nos rótulos visíveis registados pelos casos Qt. Alterar um píxel e recalcular
os hashes continua a ser rejeitado pela identidade Git da captura.

Após a publicação do pacote, uma cópia desta pasta poderá ser auditada sem
Git, worktrees antigas ou catálogo corrente:

```sh
python3 -B auditor/audit.py --evidence .
```

Requer Python com Pillow e Node para os dados estáticos arquivados. Os
binários grandes do snapshot não são necessários para auditar recibos já
capturados. A auditoria não executa novos jogos. Os testes de cópia e
adulteração serão publicados com o pacote completo.

## Limites

Linux Qt nativo, perfis novos, snapshot privado de 269 ficheiros e rede
Docker desativada. As cópias QRC conferem todos os recursos previstos pelos
geradores congelados. `audio-decode.json` conserva a descodificação por
software dos três WAV originais, repetida nas duas cópias. Isso não prova
audição, altifalantes ou pronúncia e não estende a aprovação dos 32 clips
novos a outros áudios.

Windows 10, dispositivos físicos, áudio e revisão pedagógica do professor
continuam pendentes. Pilotos com falhas de configuração do caso ou tentativas
inválidas de alias não contam como defeitos corrigidos ou jogos concluídos;
os seus diagnósticos históricos são preservados separadamente.

## Fronteiras de execução

O primeiro `adjacent-manual-complete` concluiu 125 perguntas e 25 níveis,
com recibo Qt 0 e launcher 0 observado pelo supervisor. A ferramenta externa
retornou 143. Não se infere aqui a causa. Essa execução é histórica, não entra
nas contagens selecionadas e não é descrita como sucesso em todas as fronteiras.
O percurso selecionado é `adjacent-manual-complete-rerun`, com o mesmo SHA do
caso QML original e uma nova execução integral, ainda a aguardar captura.

Cada caso selecionado terá `tool-status.json`, criado após observar o retorno
da ferramenta, ligado aos hashes do recibo nativo e do status do launcher.
A auditoria exige saída Qt, launcher pós-espera e ferramenta externa coerentes:
0 nos oito positivos; no vermelho esperado, Qt 0 e launcher/ferramenta 1.
