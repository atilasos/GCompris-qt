# Conclusão técnica dos recursos de voz em falta

Após aprovação da voz e dos nomes explícitos dos caracteres pelo professor,
foram produzidas as 32 gravações em falta: duas instruções, doze caracteres
acentuados, cinco países/territórios e treze regiões francesas. A tarefa 05
continua aberta para audição pedagógica final, testes nas atividades e Windows.

## Recursos versionados e direitos

`resources/pt-pt-voices/` contém apenas os 32 novos OGG, `texts.json`,
`manifest.json` e `NOTICE.md`. Os textos, hashes, duração, formato, versão do
Piper, hashes do modelo/configuração e referências de origem são explícitos.
O manifesto continua a indicar revisão final pendente.

Os doze caracteres são anunciados por nomes explícitos, como "a com til" e
"cê cedilhado". Nenhuma vogal simples, fonema ou gravação original foi usada
como substituto. Os 32 ficheiros somam 369419 bytes e cerca de 36,9 segundos.
O modelo, os pacotes Python e os WAV de trabalho ficam fora do repositório.

`NOTICE.md` identifica Piper GPL-3.0, o modelo distribuído num repositório com
metadados MIT e o conjunto de treino declarado CC0 no model card. O novo material
é distribuído sob GPL-3.0-or-later; os bytes e direitos dos recursos originais são
mantidos. O instalador não distribui o motor nem o modelo de síntese.

Foram alinhados dez rótulos do catálogo PO com os topónimos portugueses gravados.
`toponyms-review.json` enumera antes/depois. As fontes primárias AEP, Jornal Oficial
da UE e Conselho da UE estão em `NOTICE.md`. A concordância texto/áudio não
substitui audição da pronúncia.

## Geração reproduzível

Com Piper 1.8.0 e o modelo já disponíveis localmente, sem rede:

```bash
python3 tools/pt-pt-audio/generate_missing.py \
  --model /caminho/pt_PT-tugao-medium.onnx \
  --wav-dir /tmp/pt-pt-voices-wav
python3 tools/pt-pt-audio/encode_voices.py \
  --wav-dir /tmp/pt-pt-voices-wav --output-dir resources/pt-pt-voices
```

A configuração deve ter o nome do modelo seguido de `.json`. O gerador recusa
hashes diferentes das amostras aprovadas e uma versão diferente do Piper.
A síntese é estocástica, pelo que uma nova execução pode mudar os bytes. O build
e o instalador usam os OGG versionados e verificam os respetivos hashes; não
sintetizam áudio nem precisam do modelo. A codificação usa Vorbis/GStreamer e
verifica a descodificação de cada ficheiro gerado.

## Pacote completo e instalação

`complete_voices.py` combina o RCC original fixado pelo SHA-256 com os novos OGG.
Recusa alterações de origem, ficheiros adicionais danificados e qualquer tentativa
de substituir recursos existentes. Depois de compilar, volta a registar o RCC com
Qt e compara os hashes de todos os recursos com os inputs. O RCC original mantém-se
inalterado. O novo índice `Contents` seleciona o pacote completo para `pt` e mantém
as entradas das outras línguas.

A tarefa CMake `getAssets` compila o utilitário Qt `pt_audio_rcc_inventory` e
executa este combinador depois de obter os recursos. Quando não foram obtidas
vozes PT, a conclusão é ignorada explicitamente. Para uma pasta de vozes já
preparada, o mesmo comando funciona em Linux e Windows:

```bash
python3 tools/pt-pt-audio/complete_voices.py \
  --voices-dir /caminho/rcc/data3/voices-ogg \
  --inventory-tool /caminho/build/bin/pt_audio_rcc_inventory \
  --rcc-tool /caminho/Qt/libexec/rcc
```

A preparação Windows deve executar este passo após obter os recursos originais e
antes de copiar a árvore de instalação. Usa os mesmos OGG, ferramenta e índice padrão;
não precisa de alterações ao carregador da aplicação. A integração do script
Windows e a execução do candidato têm registo nas tarefas 07 e 13.

O combinador gera `voices-pt-2026-10-15-00-00-00.rcc`, `completion.json`, o índice,
o manifesto das adições e o aviso de origem. O manifesto de conclusão contém os
SHA-256 e tamanhos do RCC e de `Contents`, para validação do pacote distribuído.
A compilação usa RCC formato 1, sem timestamps, e a repetição com os mesmos inputs
produz os mesmos bytes.

## Evidência de execução em Linux

Foi configurado um build privado em `/tmp/gcompris-pt-complete-build` e executada
a tarefa real `getAssets`, com cópias privadas do RCC original e do índice. Não
foi alterado o build partilhado. O novo RCC tem 37222943 bytes e SHA-256
`4887e4a8c7112e6b744829c82a3476a9f322a593173d17c3b7e369fad21528ee`.

`coverage-completed.json` foi produzido a partir desse RCC real, com exportação
Qt e descodificação dos 1610 recursos. Todos passaram; os seis grupos auditados
ficaram sem lacunas. `completion.json` identifica os 1578 recursos preservados e
os 32 adicionados. Isto cobre as referências auditadas, não prova toda a seleção
dinâmica nem audição nas 203 atividades.

```bash
python3 tools/audit-pt-pt-audio.py \
  --rcc /caminho/voices-pt-2026-10-15-00-00-00.rcc \
  --output /tmp/coverage-completed.json --decode
python3 -m unittest discover -s tests -p test_complete_pt_voices.py
python3 -m unittest discover -s tests -p test_pt_pt_audio.py
```

Os testes comprovaram um ciclo vermelho/verde da embalagem real e dos rótulos
portugueses, a preservação de bytes, a seleção pelo índice, a repetição estável e
a rejeição de origem modificada, adições danificadas e substituição de originais.
Os 32 OGG versionados também foram descodificados pelo teste. `msgfmt` validou o
catálogo com os dez topónimos alterados.

## Revalidação no build integrado

O `getAssets` real do build principal foi executado após a integração e produziu
o mesmo RCC de 37222943 bytes, com SHA-256
`4887e4a8c7112e6b744829c82a3476a9f322a593173d17c3b7e369fad21528ee`.
Sete arranques nativos com perfis novos e rede desativada passaram: `polygons`,
`sixteen`, `keyboard_training`, `geography`, `geo-country`, `grammar_classes` e
`grammar_analysis`. Os logs confirmam o registo do novo RCC de 2026-10-15.
A tentativa de consultar o índice remoto falhou sem impedir o uso do pacote
local. Evidência em `build/pt-pt/completed-audio-offline/`.

O rastreio tem áudio silenciado e o contentor não tem dispositivo de som.
A descodificação automática não substitui a reprodução audível no Windows.
Na revisão dos nomes de caracteres, confirmar especialmente se o sintetizador
pronuncia `e` e `o` como nomes de letras, e não como palavras funcionais.
A gravação final de cada nome acentuado continua sujeita à revisão pedagógica.
