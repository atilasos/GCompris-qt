# Rever dois pares de vocabulário legado

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 02, 25

## Âmbito

O corpus associa fawn.ogg a «corso» e tick.ogg a «piolho». Conservar imagem,
áudio original, texto e caminhos reais capturados pelo Qt na tarefa38.
Conferir os conceitos em fonte linguística PT primária. Preparar propostas
«cervato» e «carraça» e um pacote de comparação offline com áudios/imagens.

Gerar apenas duas amostras locais, com o mesmo modelo/configuração de voz
identificados nas amostras anteriores. Não instalar substituições nem alterar
os32 ficheiros aprovados. Registar hashes, origem/licenças, textos e o caráter
provisório das propostas; verificar o pacote real e a página de audição.

A escolha pedagógica e a audição destas duas propostas exigem o professor.
Se o áudio antigo já pronunciar a palavra correta, conservar a gravação correta
em vez de a substituir. A confirmação dos32 ficheiros novos não aprova estes
pares antigos. Nenhuma aprovação pode ser atribuída pelo agente.

## Comments

Pacote e propostas prontos, ver ../legacy-word-review/README.md.
Pergunta de audição e escolha pedagógica enviada ao professor. Sem resposta
ainda; recursos do jogo e aprovação dos32 mantidos. A tarefa continua claimed.

## Aprovação e aplicação autorizada

O professor respondeu «podemos usar o que foi criado» à pergunta dos dois pares. Aprova os nomes e as duas amostras novas apresentadas no ZIP, sem escolher conservar os áudios antigos. Ver ../legacy-word-review/human-approval.json para a identidade do pacote e dos WAV. Esta autorização permite agora aplicar as duas substituições deliberadas de texto/áudio; a restrição anterior de não instalar antes da decisão já foi satisfeita. As32 gravações aprovadas permanecem intactas. O instalador publicado 38862699753 antecede esta alteração e não se apresenta como atualizado.

## Aplicação preparada para revisão

Os nomes e os dois WAV aprovados foram aplicados em build privado: 2 OGG derivados, RCC de 1610 recursos, 1576 originais e as 32 adições intactos. Novo manifesto e política de pacote distinguem as duas substituições; o RCC upstream e o pacote ouvido permanecem intactos. Provas, testes negativos e limites em ../legacy-word-application/README.md. Layout Windows extraído verificado sem execução do instalador; reprodução Windows continua pendente. Tarefa permanece claimed, sem fecho pelo implementador.

## Correções da revisão da aplicação

Preparado suplemento em ../legacy-word-application-review/README.md: LF determinístico em Contents/metadata, quatro textos raw-byte fixados com eol=lf e preparação/verificação de proveniência e NOTICE antes de publicar qualquer ficheiro, Contents por último. Negativos preservam pacote anterior; checkout Git real sob autocrlf/eol CRLF e conclusão física de 1610 recursos mantêm os hashes fixos. Nenhum áudio novo nem alteração das provas antigas. Aguarda integração e recheck separados; não se fecha a tarefa aqui.


## Answer

Resolvida a escolha humana e a aplicação delimitada de cervato e carraça.
A decisão «podemos usar o que foi criado» aprova os nomes e os dois WAV do
pacote identificado em ../legacy-word-review/human-approval.json.
Os dois OGG derivados foram aplicados sem nova síntese. As 32 gravações
anteriores e 1576 originais mantêm os bytes, num RCC de 1610 recursos.

[Spec e Standards](../review/integration44/README.md) fecharam sem achados
após corrigir LF Windows, checkout CRLF e preparação da proveniência.
O [build principal e verificação física](../runtime44/README.md) terminaram 0.
O arranque terminou 1 devido ao ID inexistente polygons2 incluído por engano;
os seis IDs reais passaram offline. Esse negativo e os logs brutos ficam intactos.

A distribuição Windows publicada antecede estas alterações. Execução,
instalação e som Windows, dispositivos, escola, aceitação docente global e
estabilidade 83 permanecem pendentes. Nenhuma coluna global do CSV muda.
