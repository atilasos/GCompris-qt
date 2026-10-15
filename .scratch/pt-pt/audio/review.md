# Áudio PT-PT: cobertura e revisão pendente

Verificação em Linux, 15 de outubro de 2026. A tarefa 05 permanece aberta.

## Evidência obtida

O utilitário Qt em `tools/pt-pt-audio/rcc_inventory.cpp` registou o pacote real
`voices-pt-2026-09-23-18-56-49.rcc`, extraindo os bytes que a aplicação recebe.
`coverage.json` contém nomes, tamanhos e SHA-256, as referências diretas por
ficheiro de atividade e as lacunas. Não se usou a contagem do catálogo PO como
prova de cobertura de gravações.

- 1578 ficheiros, todos com cabeçalho Ogg e descodificação local bem-sucedida
  com GStreamer: 1091 palavras, 201 introduções, 194 topónimos, 47 letras/números,
  24 mensagens, 11 cores e dez ficheiros em duas pastas auxiliares.
- Todas as 26 letras e os números de zero a vinte estão presentes.
- As 1090 referências sonoras do conjunto completo `lang/resource/words.json`
  com texto PT disponível têm ficheiro. As entradas numéricas usam `alphabet/`,
  não `words/`; a verificação respeita esse caminho.
- O catálogo de guiões `po/pt/gcompris_voices.po` tem 174 entradas: foram
  preenchidas 15 entradas vazias, revistas três entradas fuzzy e normalizada a
  ortografia de 42 entradas existentes. `msgfmt --check` e a auditoria do
  catálogo não encontram lacunas. Isto não regrava as introduções existentes.

Os ficheiros auxiliares `modif` e `voices_words_pt_update20260916` também foram
verificados, mas não substituem os nomes de recursos que os jogos pedem.

## Lacunas reais

| Grupo | Ficheiros em falta | Consequência e ação |
| --- | --- | --- |
| Introduções | `intro/polygons.ogg`, `intro/sixteen.ogg` | Falta a instrução falada. Guiões PT preparados; aprovar voz antes de gerar recursos finais. |
| Teclado português | `alphabet/U00E0.ogg`, `U00E1.ogg`, `U00E2.ogg`, `U00E3.ogg`, `U00E7.ogg`, `U00E9.ogg`, `U00EA.ogg`, `U00ED.ogg`, `U00F3.ogg`, `U00F4.ogg`, `U00F5.ogg`, `U00FA.ogg` | Correspondem a à, á, â, ã, ç, é, ê, í, ó, ô, õ, ú. Afetam o áudio de caracteres em `gletters`, `keyboard_training`, `wordsgame` e outros consumidores. Não usar a vogal não acentuada como substituto. Decidir e validar pedagogicamente o que cada gravação deve pronunciar. |
| Geografia | `geography/bahrain.ogg`, `nauru.ogg`, `palestine.ogg`, `singapore.ogg`, `wallis_and_futuna.ogg` | Referências literais sem gravação. Rever pronúncia e grafia portuguesa dos topónimos antes de gravar. |
| Regiões francesas | Treze referências sob `france/`, enumeradas em `coverage.json` | Não existe esta pasta no pacote PT. Confirmar atividade/modo que usa cada referência e produzir as gravações necessárias. |

Referências diretas não resolvem toda a seleção dinâmica: atividades que herdam
outras atividades, nomes de ficheiros montados em execução e o encaminhamento
por locale requerem os testes interativos da tarefa 06.

## Reprodução e limites

A descodificação percorreu todos os 1578 ficheiros com
`filesrc ! decodebin ! audioconvert ! fakesink`, sem descarregamentos e sem
saída de som. Verifica bytes e codec no Linux, mas não prova que a gravação diz
a palavra certa, que os sons das letras são pedagogicamente adequados ou que a
saída de som funciona num jogo. A audição real, a integração dos recursos em
cada atividade e a reprodução em Windows 10 x64 continuam pendentes.

Para repetir, são necessários C++/Qt6Core, Python3, pkg-config e GStreamer:

```bash
python3 tools/audit-pt-pt-audio.py \
  --rcc build/pt-pt/share/gcompris-qt/rcc/data3/voices-ogg/voices-pt-2026-09-23-18-56-49.rcc \
  --output .scratch/pt-pt/audio/coverage.json \
  --export-dir /tmp/gcompris-pt-audio \
  --decode
python3 -m unittest discover -s tests -p test_pt_pt_audio.py
```

O auditor gera um inventário e termina com sucesso mesmo havendo gravações em
falta. A aprovação exige ler as listas `missing`, o resultado `decode` e os
resultados de audição; gerar um relatório não fecha a tarefa.

## Audição pelo professor

As gravações existentes devem ser aproveitadas após audição. Depois de exportar
com o comando anterior, os ficheiros ficam em
`/tmp/gcompris-pt-audio/gcompris/data/voices-ogg/pt/`.

| Amostra existente | Verificar |
| --- | --- |
| `alphabet/U0061.ogg`, `U0065.ogg` | A atividade pretende o nome da letra ou o som? Estas gravações adequam-se ao exercício? |
| `alphabet/U0072.ogg`, `U0078.ogg`, `U007A.ogg` | Nomes/sons e pronúncia europeia de r, x, z. |
| `alphabet/U0036.ogg`, `16.ogg`, `17.ogg` | Seis, dezasseis e dezassete; inteligibilidade e adequação PT-PT. |
| `words/train.ogg`, `bus.ogg`, `girl.ogg` | Correspondência com comboio, autocarro e rapariga no texto PT. |
| `intro/compass.ogg`, `adjacent_numbers.ogg` | Correspondência com os objetivos e a instrução atual do jogo. |
| `intro/tens_complement_calculate.ogg` | Confirmar se a gravação inclui escrever o resultado; o guião fuzzy antigo omitia essa parte. |

Os metadados Vorbis das amostras existentes declaram `GPL V3+`, com artista
`IFILP-TEC` (letras e números, 2009) ou `(VitordeMatos)` (palavras e introduções).
Estes dados descrevem as amostras inspecionadas, não certificam os direitos de
todas as gravações do pacote. Não foram alteradas ou substituídas gravações.

## Três amostras sintéticas preparadas

As amostras de introdução de `polygons`, de `sixteen` e de vocabulário PT-PT
estão em `samples/`. Foram geradas com Piper sem rede. O
[registo das amostras](samples/README.md) identifica textos, modelo, ambiente,
limites da verificação de licença e aprovação pendente. Não foram distribuídas
como recursos de atividade nem geradas gravações em escala.
