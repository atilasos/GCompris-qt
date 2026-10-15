# Revisão de dois pares antigos

Pacote preparado, ainda sem decisão do professor. Não há alterações aos textos
ou aos áudios distribuídos com o jogo. As32 gravações aprovadas e o ZIP ouvido
mantêm os seus bytes/estados; este material compara apenas dois pares antigos.

A captura Qt em ../functional-word-letters/linguistic-captures identifica imagens,
OGG antigos, texto e hashes. A inspeção visual mostra uma cria de cervídeo e o
desenho do recurso tick. Propõem-se «cervato» e «carraça». O Priberam define
[cervato](https://dicionario.priberam.org/cervato) como veado jovem e
[carraça](https://dicionario.priberam.org/carra%C3%A7a) como um acarídeo parasita.
A identificação por uma ilustração e a escolha pedagógica precisam do professor.
O agente não afirma ter ouvido/transcrito as duas gravações antigas.

Foram geradas duas amostras WAV locais com Piper1.8.0, modelo/configuração
originais identificados pelos mesmos hashes das amostras anteriores, sem rede.
O motor/modelo foram montados só para leitura, tal como o checkout; apenas o
diretório novo de saída podia ser escrito. O manifesto conserva texto e hashes.
As imagens mantêm crédito Art4Apps/CC BY-SA3.0; NOTICE identifica origem e
licenças de imagens, áudio antigo e propostas. Modelo/motor não entram no ZIP.

O ZIP contém9 membros:2 imagens,2 OGG antigos,2 WAV propostos, HTML, manifesto
e NOTICE. Foi reaberto e verificado por CRC e SHA de todos os media. O Chromium
do Hub research mostrou quatro players e duas imagens. `browser-test.json`
não tem erros de consola/browser ou pedidos pendentes; as sessões foram fechadas.
T3 preview não está exposto nesta sessão. O Hub não testa file:// no Windows.
Os clips duram menos de um segundo; o mostrador arredonda-os para0:00.
A inspeção dos WAV e o GStreamer identificaram duração/canais válidos.

[Pacote local](../../../build/pt-pt/audio-review/dois-pares-legados/revisao-2-pares.zip).
`package-verification.json` fixa o ZIP mostrado ao professor; não será sobrescrito.
A pergunta de revisão foi enviada em16/10/2026, hora local, incluindo a opção
de conservar um áudio antigo se já pronunciar corretamente o nome escolhido.

As propostas continuam pending. A eventual aprovação destas amostras WAV não
será transferida automaticamente para ficheiros diferentes; qualquer recurso
de distribuição terá proveniência e estado de revisão próprios. Não instalar
substituições ou declarar concluída a revisão linguística sem essa decisão.

## Reprodução

`build_review.py` usa o ambiente Piper local já existente e recusa modelo ou
configuração diferentes, bem como diretório de saída existente. Não descarrega
ficheiros. No ambiente Python3.12 com Piper1.8.0 executar:

```sh
python .scratch/pt-pt/legacy-word-review/build_review.py \
 --model /caminho/pt_PT-tugao-medium.onnx --output-dir /novo/pacote
```

O pacote concreto usa as amostras fixadas em samples/; a síntese é estocástica
e uma repetição produz outros bytes, sempre sujeitos a revisão própria.
