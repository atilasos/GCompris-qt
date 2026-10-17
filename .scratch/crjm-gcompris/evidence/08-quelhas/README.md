# Ticket 08: Quelhas para duas pessoas

Data: 2026-10-17. Base inicial b78753319, ancestral confirmado antes de editar.
O seam confirmado é a aplicação Qt real, começando no menu, com eventos nos
controlos originais. Não são substituídos regras, tabuleiro ou vencedor.

## Reprodução

Na worktree ou checkout com a atividade, usar uma pasta de saída nova:

```sh
python3 tools/run-native-qml-case.py \
  --resource-snapshot /tmp/crjm-native-base \
  --binary /home/proteu/Projetos/GCompris-qt/build/pt-pt/bin/gcompris-qt \
  --activity menu --from-menu \
  --extra-activity dominorio --extra-activity quelhas \
  --qml-file src/activities/menu/Menu.qml \
  --case tests/crjm/quelhas.qml \
  --output /tmp/quelhas-08-recheck --offline
```

O runner compila RCC da atividade e catálogo do menu na implantação privada.
Qt 6.10.2, pt_PT, renderização software/offscreen sem GPU, Docker sem rede,
snapshot imutável de recursos. `result.json` regista os hashes de origem,
caso, binário, recursos e isolamento. Não se recompilou o executável C++.

## Resultados

- `red-menu`: atividade ainda inexistente. Uma falha nativa ao não encontrar
  Quelhas na pesquisa do menu; zero erros QML.
- `green-menu`: a atividade abre pelo cartão real. Dois passes, zero falhas.
- `red-keyboard`: depois da implementação inicial, o percurso completo já
  passava, mas um novo teste de Tab para Trocar falhou. Os GCButton herdavam
  Qt.NoFocus. Foi aplicado Qt.StrongFocus nos quatro botões da atividade.
- `native`: dois passes, zero falhas, zero erros QML. O caso abre pelo menu,
  rejeita comprimento um, orientação errada, diagonal e sobreposição; corrige
  extremos de três para duas casas; confirma por teclado; troca por Tab e
  Espaço, preservando pedras, consumindo o turno e alterando os papéis sem
  trocar as identidades. Prossegue com ambos os novos papéis, reinicia e
  completa os nove segmentos de referência através de eventos reais.
- O final mostra participante 2 vencedor e participante 1 último jogador,
  apesar de restarem casas vazias verticalmente adjacentes. Bloqueia ações
  após o resultado. Ajuda preserva seleção, pedras e turno. Reinício repõe
  orientações e tabuleiro. Regressa ao menu.
- Capturas desktop 1100×700 e retrato 600×900 inspecionadas. Tabuleiro completo,
  textos e controlos visíveis sem sobreposição; casas acima de 40 px nos dois
  exemplos observados. Preview e resultado mostram os segmentos completos.

Os testes injetam QtTest apenas no menu. Usam pesquisa, cartão, botões e casas
reais e consultam texto visível, enabled e foco. A sequência fixa de referência
é independente da implementação. Não chamam as funções de regras nem alteram
estado interno. O teste de toque usa eventos sintéticos, não um tablet físico.
Sem validação com crianças, som ou dispositivos físicos modestos nesta entrega.
Tux e aprendizagem guiada ficam no ticket 09.

## Origem e permissões

Regras e resultado de referência da plataforma CRJM de atilasos,
https://github.com/atilasos/crjm, commit
b206a7b4948673be935a5cb6a5a84df92d3ba6c2.
A implementação QML/JavaScript e o ícone foram escritos independentemente.
Não foram copiados código, imagens ou exercícios CRJM. O GPL-3.0-or-later nos
novos ficheiros não relicencia componentes CRJM.

O regulamento oficial regional confirma tabuleiro 10×10, segmentos ≥2,
último jogador perde e troca inicial consumindo o turno:
https://projetosdre.madeira.gov.pt/crjmram/quelhas/ e o documento aí ligado
https://projetosdre.madeira.gov.pt/crjmram/wp-content/uploads/sites/5/2026/09/Tabuleiro_Regras_Quelhas1.docx
SHA256 7df37e66c0bdda90b687e914fe21df23cce59e5d162c810f14c949f5d469022c.
A sequência de nove segmentos foi previamente executada contra as regras CRJM;
é uma posição de teste, não uma cópia da implementação do motor.

## Verificação após integração

Merge do tip integration/crjm-games 210005497 para a branch de trabalho,
commit 2201a5049. O único conflito foi Progress do ticket 08, preservado
resolved porque os testes e evidências já estavam completos.
O mesmo comando foi repetido depois do merge com a opção adicional
`--extra-activity gatos_caes`, saída `/tmp/quelhas-08-merged`.
Resultado em `merged/`: dois passes, zero falhas, zero erros QML, sem rede.
A entrada do catálogo dos dois jogos está preservada.
