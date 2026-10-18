# Interfaces nativas dos jogos

Progress: resolved

- [Tarefa](issues/01-reimaginar-interfaces.md).
- [Relatório](README.md).
- Branch de trabalho: `fix/crjm-native-ui`, a partir de `b261310d9`.
- Destino: `integration/crjm-games` e build local.

O pedido é rever as oito interfaces no contexto do GCompris. As capturas do
utilizador revelaram uma falha de escala não coberta pela aceitação anterior.
A reprodução configura o ecrã principal Qt, além da janela. A implementação
preserva as regras e coloca o tabuleiro antes dos controlos secundários.


A tarefa está resolvida. A build local foi atualizada após 96 perfis de interface,
18 percursos funcionais e verificação dos 280 ficheiros pelo manifesto. A build
anterior permanece disponível para comparação e reprodução do caso vermelho.
