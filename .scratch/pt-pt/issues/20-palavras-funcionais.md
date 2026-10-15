# Verificar Palavras que caem em PT-PT

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 02, 04

## Âmbito

Todos os três níveis PT de wordsgame, modos de caso e dez velocidades.
Respostas certas/erradas por eventos nativos, palavras completas, reinício após
prefixo errado, acentos/cedilha presentes nos dados, transições, ajuda e menu.
Perfil novo offline e evidência com hashes. Sem aceitação de teclado físico,
áudio, Windows ou revisão docente.

## Answer

Quatro casos nativos passaram com dados PT compilados em RCC privado: seis
percursos completos (três níveis × dois modos), 90 palavras e 233 erros rejeitados;
vinte configurações velocidade/modo com teclado virtual e reinício; perda pela
animação real e recuperação; navegação/ajuda/menu. Os três caracteres especiais
existentes no deck, ç/í/ú, foram aceites corretamente e rejeitados sem diacrítico
nos dois modos. Todos os 147 dados passaram a verificação estrutural e o adaptador
IME passou o self-test. A correção música da tarefa19 foi integrada e exercitada;
esta tarefa não alterou produção.

[Procedimento, evidência, hashes e limites](../functional-words/README.md).
Aceitação global Linux, Windows, audição, teclado físico e professor continuam
pendentes. Mapa/CSV ficam com o integrador; nenhum build principal foi escrito.
