# Gravações adicionais em português de Portugal

Estas 32 gravações foram geradas neste fork para preencher ficheiros ausentes.
Os nomes dos ficheiros e os textos exatos constam de `texts.json`; `manifest.json`
regista hashes, duração, formato e versão do sintetizador. Não substituem nenhuma
das 1578 gravações existentes no pacote original.

O professor aprovou a voz, o ritmo e a pronúncia das amostras para gerar instruções
e topónimos, e aprovou nomes explícitos dos caracteres acentuados, como "a com
acento agudo", "a com til" e "cê cedilhado". Estes nomes não substituem fonemas.
O professor aprovou a pronúncia e os textos das 32 gravações em 15 de outubro de 2026.
O campo teacher_review do manifesto identifica os textos e os hashes aprovados.
A reprodução nas atividades e nos computadores Windows continua a ser verificada.

## Origem e licenças

- Novos textos, gravações e ferramentas deste projeto: GPL-3.0-or-later,
  conforme o ficheiro `LICENSES/GPL-3.0-or-later.txt` do código-fonte.
- Síntese local, sem rede, com Piper 1.8.0, motor GPL-3.0:
  https://github.com/OHF-Voice/piper1-gpl
- Voz `pt_PT-tugão-medium`, modelo e configuração originais, sem alterações:
  https://huggingface.co/rhasspy/piper-voices/tree/main/pt/pt_PT/tug%C3%A3o/medium
- O repositório distribuidor do modelo declara MIT nos metadados:
  https://huggingface.co/rhasspy/piper-voices/blob/main/README.md
- O model card declara conjunto de treino CC0, língua PT-PT e 22050 Hz:
  https://huggingface.co/rhasspy/piper-voices/blob/main/pt/pt_PT/tug%C3%A3o/medium/MODEL_CARD

O modelo, o motor e os pacotes Python não são distribuídos com o jogo.
Os hashes do modelo e da configuração estão no manifesto. A configuração usa
os dados eSpeak `pt`, identificados no motor como Portuguese (Portugal), com
fonemas `pt-pt`. A síntese pode gerar bytes diferentes noutra execução; os OGG
versionados são os recursos a distribuir e a verificar pelos hashes.

As gravações originais mantêm os bytes e as licenças de origem. O manifesto de
conclusão do pacote identifica o SHA-256 do RCC original e confirma a preservação
de todos os recursos antes de publicar o novo RCC e o seu índice Contents.

## Topónimos

Usaram-se formas portuguesas para os nomes gravados. Fontes primárias consultadas:

- AEP, Flash Mercado França 2025, mapa das regiões em português:
  https://www.portugalbusinessontheway.com/wp-content/uploads/2025/07/AEP_BOW24.25_Flash-Mercado-Franca.pdf
- Jornal Oficial da UE, Centro-Vale do Loire, País do Loire e Grande Leste:
  https://eur-lex.europa.eu/legal-content/PT/TXT/PDF/?uri=OJ%3AL%3A2022%3A068%3AFULL
- Decisão UE 2025/1708, Auvérnia-Ródano-Alpes e Borgonha-Franco Condado:
  https://eur-lex.europa.eu/legal-content/PT/TXT/PDF/?uri=CELEX%3A02025D1708-20260320
- Conselho da UE, Barém:
  https://www.consilium.europa.eu/pt/infographics/eu-gcc-trade/

A grafia não certifica a pronúncia gerada. Os topónimos fazem parte da lista de
audição final pelo professor.
