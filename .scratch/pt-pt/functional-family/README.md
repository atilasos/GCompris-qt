# Relações familiares, tarefa 86

Pronto para revisão independente. Foram concluídos os 18 desenhos de `family` e os 18 de `family_find_relative`: 18 respostas corretas e 28 pares distintos corretos, com progressão natural, mais 36 erros seguidos de reparação. Os 28 são todos os pares não ordenados derivados do grafo nos 18 pedidos do segundo modo. Dois controlos separados incluem uma seleção pela ordem inversa. Não se apresenta uma campanha de todas as permutações de ordem de cliques.

Não existem conjuntos selecionáveis, configuração da atividade, botão Recarregar, entrada de texto ou Score numérico nesta interface. Cada desenho corresponde a um nível e uma pergunta; a ordem dos 18 é baralhada ao entrar. Os dois modos são atividades distintas. As 18 relações inventariadas são pai, mãe, avô, avó, neto, neta, irmão, irmã, primo, tio, tia, sobrinho, sobrinha, sogro, sogra, cunhado, cunhada e genro. Nora aparece como opção nos desenhos de afinidade, embora não seja o pedido principal de um dos 18 desenhos.

## Oráculo e limites visuais

O observador lê somente os SVG realmente desenhados nas pessoas, coordenadas e dimensões dos círculos/linhas/anéis, bordas branca/laranja, legendas Eu/?, opções textuais e a instrução. Não lê `nodeWeight`, `currentState`, modelos, arrays de dados/soluções, resposta correta, propriedades de validador nem históricos. Nenhuma chamada ao validador interno ou alteração de estado/progresso resolve exercícios. O código aplica apenas cliques, setas de navegação, Escape e menu reais.

O grafo divide segmentos ortogonais nas interseções. Para cada pessoa, segue ligações para cima até às primeiras pessoas da geração anterior. As linhas de cônjuges são determinadas pelos anéis; não são seguidas lateralmente na geração inicial para inventar pais de um cônjuge. Ascendência, descendência, irmãos, primos e afinidade são derivados desse grafo. Python recalcula independentemente as relações a partir dos registos visuais e compara-as com o oráculo QML. Fixtures geométricas literais verificam ascendência, irmãos/primos/tios/sobrinhos e afinidade.

**Ambiguidade a rever pelo professor:** os rostos não têm nomes nem legendas explícitas de sexo/género. A classificação de 12 imagens em categorias iconográficas convencionais está documentada no código e na folha `icons.png`, renderizada dos SVG reais. Laço, cabelo, barba ou acessórios não determinam sexo/género de uma pessoa. Portanto, os testes de termos específicos como pai/mãe são condicionados às convenções visuais do jogo e não certificam que o aluno consegue inferir esses termos sem ambiguidade. A geração e as ligações são verificadas geometricamente; os anéis indicam casais conforme a ajuda. Não se atribui a um aluno certeza que não está legendada. Cenas não ortogonais, imagens desconhecidas ou anéis sem casal reconhecível são recusados pelo oráculo.

## Correção PT e fases

- `baseline` 1efc489b2: inventários completos e os dois vermelhos lexicais. O modo `family` apresentava Afilhada como opção para daughter-in-law; o segundo modo pedia Afilhado para son-in-law.
- `translated` 90bd961d2: apenas dois `msgstr` passam a Nora e Genro. Os mesmos casos exatos dos vermelhos percorrem todos os 18 desenhos e passam nos dois consumidores. Todas as campanhas completas e os dois controlos pertencem a esta fase.

A distinção lexical assenta no Dicionário Priberam, fonte primária. Ver `lexical-sources.md`. Não houve alterações aos dados, motor, desenhos ou áudios.

Os dois controlos verificam navegação anterior/seguinte e extremos 1↔18, ausência dos controlos não oferecidos, ajuda PT/Escape, resposta correta após fechar a ajuda e regresso ao menu real. No segundo modo, uma seleção parcial é limpa por navegação e retorno; clicar duas vezes na mesma pessoa desmarca-a nos 18 níveis. O primeiro modo tem apenas uma escolha por pergunta, sem edição parcial persistente ou botão de reinício. Cada erro mantém a pergunta e o grafo, cada acerto produz lion_good e o nível seguinte, incluindo 18→1. Os erros produzem lion_bad; não foram usados para descobrir respostas.

## Arquivo físico

`capsule/capture.json` e `capsule/objects.zip` preservam fontes/PO/ferramentas das duas revisões, casos exatos, recibos, screenshots, quatro camadas de retornos observados, RCC/QM privados reais e extrações QResource/TS de cada execução. Os deployments únicos foram mantidos desde o primeiro run; o arquivo não depende deles nem os reconstitui. Os seis RCC canónicos, core e duas atividades nas duas fases, têm binários e extrações reais. As fontes foram congeladas atomicamente antes dos pools. Snapshots físicos privados de 269 ficheiros foram copiados sem ligações ao build principal, que não foi modificado por esta tarefa. O executável é identificado por SHA; o arquivo não duplica os restantes recursos alheios aos dois jogos do snapshot de cerca de 1 GB.

Todos os recibos nativos terminaram com processo Qt 0. Os dois vermelhos têm launcher/supervisor/ferramenta 1 devido às assertions lexicais, independentemente do Qt 0; os restantes têm 0 em todas as camadas. `tool-exit.json` só foi escrito depois de observar a resposta final real de `tools.write_stdin`. A imagem Docker efetiva é sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b. Rede none, host RO, apenas perfil/saída privados RW, UID/GID 1000 e propriedade verificada. Nenhum processo nativo fica necessário para a evidência.

```sh
python3 tests/functional_family/audit.py
python3 -m unittest discover -s tests/functional_family -p 'test_*.py'
```

O auditor necessita somente de `audit.py`, `oracle.py` e uma cópia física de `capsule`; aceita `--capsule COPIA`. Não executa Git, Qt ou comandos externos nem abre caminhos históricos. A âncora SHA literal é externa ao arquivo; o auditor exclui-se do seu próprio pacote para evitar uma dependência circular. Os objetos são identificados pelos seus bytes, e cada extração instrumentada é confrontada com a fonte histórica e o caso exato. Adulterações de RCC, QM, QML, cobertura vazia, status e reencadeamento coerente de PO/fontes/recibos/status/objetos/selo são rejeitados. Python -O é recusado. Executor e observador recusam saídas existentes sem reescrever os bytes anteriores.

## Limites

Validação Linux, Qt software e eventos sintéticos numa janela de 800×800. As três WAV do core foram descodificadas para fakesink por fase; não houve audição e o GCompris iniciou sem som. Não se transfere aprovação das 32 gravações nem da tarefa 44. Windows 10/11, dispositivos físicos, audição, pronúncia, acessibilidade, revisão docente, estabilidade da tarefa 83 e aceitação global continuam pendentes. As convenções iconográficas de género e a apresentação pedagógica precisam de revisão humana explícita.
