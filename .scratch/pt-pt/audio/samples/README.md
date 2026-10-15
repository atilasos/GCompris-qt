# Amostras de voz sintética para aprovação

Estas três amostras foram geradas localmente com Piper 1.8.0 e a voz
`pt_PT-tugão-medium`, sem ligação à rede durante a síntese. Não foram instaladas
nos jogos. O professor ainda não aprovou a pronúncia, a velocidade ou a clareza.

| Ficheiro | Finalidade |
| --- | --- |
| `polygons.wav` | Instrução de uma atividade sem gravação PT. |
| `sixteen.wav` | Instrução de uma atividade sem gravação PT. |
| `vocabulario.wav` | Avaliar pronúncia europeia: comboio, estação, autocarro, dezasseis e dezassete. |

`manifest.json` contém o texto exato, a versão do sintetizador, as características
dos WAV e os SHA-256 do modelo, da configuração e das amostras. A síntese é
estocástica; uma repetição pode gerar outros bytes. `requirements.lock` regista
os pacotes usados num contentor Python 3.12. O modelo e os pacotes ficam fora
do repositório; nenhuma dependência foi instalada no Python do sistema.

## Origem e direitos

- [Piper: instruções oficiais](https://github.com/OHF-Voice/piper1-gpl/blob/main/docs/CLI.md).
  Motor distribuído sob GPL-3.0. Não faz parte do instalador do jogo.
- [Modelo e configuração](https://huggingface.co/rhasspy/piper-voices/tree/main/pt/pt_PT/tug%C3%A3o/medium).
  A configuração original foi usada sem alterações.
- [Model card da voz](https://huggingface.co/rhasspy/piper-voices/blob/main/pt/pt_PT/tug%C3%A3o/medium/MODEL_CARD).
  Declara língua PT-PT, um locutor, 22050 Hz e conjunto de treino CC0. Indica
  afinação a partir de `lessac` inglês americano. A declaração CC0 refere-se
  expressamente ao conjunto de treino, não constitui por si uma declaração de
  licença dos pesos ou das saídas. Os direitos de distribuição dos recursos
  finais devem ser confirmados antes da sua inclusão no instalador.
- Os textos das três amostras foram preparados neste trabalho. Nenhum fonema,
  nome de letra ou gravação existente foi substituído.

O modelo pede a voz eSpeak `pt`. No Piper 1.8.0 usado, o ficheiro
`piper/espeak-ng-data/lang/roa/pt` declara `Portuguese (Portugal)`, os aliases `pt`
e `pt-pt` e `phonemes pt-pt`. O código `pt` não foi interpretado como confirmação
de variante linguística sem inspecionar estes dados. A audição humana continua
obrigatória.

## Repetir a geração

Com o modelo já disponível localmente e o ambiente Piper instalado, executa:

```bash
python3 tools/pt-pt-audio/make_samples.py \
  --model /caminho/pt_PT-tugao-medium.onnx \
  --output-dir .scratch/pt-pt/audio/samples
```

O nome do ficheiro de configuração deve ser o nome do modelo seguido de
`.json`. Os hashes permitem verificar o modelo e a configuração usados aqui.

Para aprovar a voz, ouvir as três amostras e avaliar pronúncia, ritmo e
inteligibilidade para crianças. Uma aprovação desta voz não aprova a produção
em massa nem os sons das letras, que têm uma revisão pedagógica própria.
