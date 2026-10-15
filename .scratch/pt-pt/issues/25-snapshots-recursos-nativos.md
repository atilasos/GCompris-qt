# Fixar os recursos das execuções QML nativas

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 02

## Âmbito

Criar snapshots independentes de binário, `share/gcompris-qt` completo e
`lib/qml` local. Copiar transitivamente symlinks, recusar alterações durante a
cópia e verificar um manifesto SHA-256. Reutilizar a cópia pelo launcher nativo.
Executar o processo Qt offline com o UID/GID local para permitir limpeza normal.

## Aceitação

- Ficheiros de origem alterados após copiar não alteram o snapshot.
- Manifesto ou ficheiros adulterados são rejeitados.
- Nenhum symlink do snapshot aponta para o build mutável.
- Rede desativada e host só para leitura; perfil e saída privados.
- Caso Qt normal curto passa, gera ficheiros com o dono local e limpa sem
  `ignore_errors`.
- Não alterar o build principal nem misturar investigação de falhas.

## Comments

Os seams autorizados são criar/verificar o snapshot e reutilizá-lo no launcher.
Fixtures pequenas verificam os contratos de ficheiros, sem processos Qt nos
unitários. O caso de navegação existente verifica o caminho Qt normal.

## Answer

`tools/native_qml_resources.py` cria a cópia transitiva e verifica o manifesto.
O launcher aceita `--resource-snapshot`, usa o binário copiado e substitui apenas
os dois recursos privados da checkout. O GNU chroot do host aplica
`--userspec=1000:1000` nesta máquina. A verificação de dono usa `lstat`, incluindo
symlinks do PulseAudio cujo destino temporário termina com o contentor.

Quatro testes unitários passaram. Cobrem cópia de symlinks e diretórios vazios,
independência após alterar/remover origens, adulteração de ficheiro/manifesto,
recusa de alteração do conteúdo ou timestamp durante a cópia e remoção parcial.

O caso existente `click_navigation.qml`, com `--start-level 3`, passou sem rede:
2 passes, 0 falhas, código 0 e sem timeout. O snapshot contém 269 ficheiros.
Todos os ficheiros privados pertencem a UID/GID 1000:1000 e a remoção do deployment
terminou normalmente. O launcher não recebeu `--binary` neste ensaio final,
confirmando que a reutilização depende apenas do snapshot.

- Resultado local: `build/snapshot-navigation-v1/result.json` na worktree
  `pt-resource-snapshot`, conservado fora do Git.
- SHA-256 do manifesto: `53d6aee09d459e456a5785adab238c0971f4050d879ea036f9fd3325ff03d0e4`.
- SHA-256 do executável: `3a226ee745c25aa8cf5e77d7cfb438c83dc6956091e6230053598cca659314bb`.
- ID real da imagem: `sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b`.

Procedimento reproduzível em `tests/native_qml_resources/README.md`.
Este ensaio valida o launcher e o snapshot. Não substitui a aceitação das
atividades nem fixa as bibliotecas Qt do sistema.
