# Associações lógicas em PT-PT

Os sete níveis concluíram três sequências cada: 21 perguntas, 84 frutas
escolhidas corretamente e 21 escolhas erradas rejeitadas. Houve sete Bonus
com transições naturais. Não foi necessária alteração de produção.

O teste lê as oito imagens desenhadas da referência e as quatro primeiras
imagens da resposta. Constrói uma correspondência um para um e escolhe as
quatro frutas em falta pelas imagens expostas. Não lê answerIndex, modelos,
modelData ou o índice aleatório, não chama o motor para obter respostas e
não modifica progresso ou temporizadores. Entradas alternam rato e teclado,
com setas e Espaço/Enter/Return reais. A resposta completa desenhada é
conferida contra a correspondência visual independente.

O inventário estático verifica os 28 exemplos publicados, incluindo um
exemplo duplicado. Há 27 exemplos distintos ao contar cada nível separadamente. Todos são identificáveis
pelos quatro pares iniciais. As perguntas aleatórias observadas não aprovam
todas as permutações de frutas ou todos os exemplos interativos possíveis.

O caso de controlos verifica setas esquerda/direita, seleção por teclado,
reinício após progresso, navegação circular, ajuda em PT, Escape, nova entrada
após ajuda e regresso ao menu. Não existe seletor de datasets nesta atividade.

O inventário QRC copia 16 recursos originais: imagens de frutas, ponto de
interrogação, fundo, ícone, componentes e três WAV. Todos os SVG carregam com
Image.Ready. Os WAV descodificaram para GStreamer fakesink, sem reprodução
física nem audição. Uma captura do piloto foi também inspecionada visualmente.

Três casos finais positivos, jogo/controlos/inventário, usam Qt Linux original,
PT-PT, perfis novos e Docker sem rede com snapshot privado de 269 ficheiros.
Os processos Qt e lançadores terminaram com 0. O piloto separado cobre só o
primeiro nível e fica fora da contagem principal.

A cópia supervisor.py é byte a byte o helper dd5a27b9b. O parent grava
launcher-status.json apenas depois de subprocess.run terminar, ligando o
retorno externo ao SHA do recibo, caso e lançador. O auditor exige esse
registo e confere o arquivo Git imutável, sem depender de caminhos antigos
ou do catálogo corrente. A revisão final é registada separadamente.

Aceitação global Linux, Windows 10 da escola, dispositivos físicos, touch,
audição e revisão docente continuam pendentes. As provas acima não aprovam
estes critérios.

O auditor final passou com três casos positivos, sete níveis, 21 perguntas e
15 padrões diferentes observados, sem os confundir com os 28 exemplos
publicados. Oito testes puros passaram, incluindo correspondência conhecida,
prefixo ambíguo rejeitado, cópia independente e adulteração de fonte/catálogo
com hashes recalculados, retorno externo, caso e imagem. Os recibos e sidecars originais
são também conferidos byte a byte contra o commit imutável de captura.

```sh
python3 tests/functional_algorithm/audit.py
python3 -m unittest discover -s tests/functional_algorithm -p 'test_*.py'
```
