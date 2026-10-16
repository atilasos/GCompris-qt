# Verificação do auditor88

A cápsula irmã `../capsule` e a fonte do auditor em `ad173141b` ficaram
inalteradas durante a execução final. A sincronização posterior da integração
acrescentou somente documentos do tracker. `portable-final.json` conserva os
argv, hashes de todos os ficheiros de código copiados, hash do índice, imagem,
wheel, stdout/stderr e retornos reais de duas execuções Docker: normal e `-O`.
O wrapper terminou0, observado externamente na sessão49151/chunk e64107.
Os dois processos interiores terminaram0 e a verificação local confirmou que os
hashes do código copiado coincidem com todos os ficheiros atuais correspondentes.

Ambas as execuções usaram Python3.12-slim pelo ID
`sha256:a6e34c598f2467ed0e9a8d349809fcd8b5c603269512df273a0bb1784edc11b1`,
Pillow12.1.1 instalado exclusivamente a partir do wheel local com o SHA256 PyPI
fixado, rede desativada e uma cópia física de código/provas. Não existiam Git,
Qt ou a árvore original. A instalação usa tmpfs com `exec` para permitir carregar
a extensão C de Pillow; o resto do sistema de ficheiros permanece só de leitura.

Cada execução aceitou53 tabuleiros,367 peças,35 diferenças,53 Bonus naturais,
53 grupos de erros reparados, três casos de controlos e dois pares lexicais
43 registos por cor/seis divergências antes/zero depois. Separou19 vitórias
históricas parciais. Rejeitou a cópia adulterada por âncora; quando o teste
confiou deliberadamente na nova âncora da adulteração, as verificações físicas
passaram e a comparação independente de píxeis rejeitou o alvo alterado.
Também rejeitou uma campanha vazia. A execução host com `-O` e os oito testes
unitários em cada modo estão conservados nos ficheiros adjacentes.

`portable-prerequisite-failure.log` preserva a primeira tentativa: o tmpfs Docker
sem `exec` impedia mapear a extensão de Pillow. Terminou1; foi uma restrição do
executor, sem conclusão sobre o produto. `portable-preliminary.json` conserva
as duas primeiras execuções bem sucedidas; a final acrescenta os hashes de todo
o código copiado. Nenhuma destas saídas reescreve a cápsula ou recibos nativos.
`tool-observations.json` regista as referências da conversa às conclusões reais,
como declaração do agente e sem alegar assinatura autónoma da plataforma.

Wheel físico fora do Git, disponível na árvore autora em
`build/visual-audit-dependencies/pillow-12.1.1-cp312-cp312-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl`.
As limitações de Qt do anfitrião, Windows, dispositivo/áudio humano e aceitação
docente mantêm-se as documentadas no auditor e no README principal.
