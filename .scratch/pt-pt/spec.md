# GCompris integralmente funcional em português de Portugal

Status: ready-for-agent
Progress: open

Âmbito confirmado pelo professor em 15 de outubro de 2026.

## Resultado pretendido

Todas as atividades disponibilizadas nesta versão, com todos os níveis e modos,
funcionam em português de Portugal. A lista inicial tem 203 atividades em
`src/activities/activities.txt`. Uma atividade problemática permanece no âmbito;
ocultá-la ou desativá-la não constitui uma correção.

O desenvolvimento e os testes locais decorrem em Linux. A entrega obrigatória é
um instalador para Windows 10, com permissões administrativas disponíveis na
escola. O instalador inclui todos os recursos para jogar sem Internet, incluindo
num computador que nunca descarregou esses recursos.

## Critérios de aceitação

- Menus, instruções, ajuda, mensagens, palavras, respostas aceites e vozes usam
  português europeu e ortografia atual. Não há recurso involuntário a inglês ou
  português do Brasil.
- Cada atividade permite iniciar, jogar e concluir os níveis e modos. As
  verificações abrangem respostas certas e erradas, teclados portugueses,
  maiúsculas, minúsculas e caracteres portugueses quando aplicáveis.
- Os dados de todos os níveis têm verificação automática. Cada atividade e modo
  têm testes interativos. Níveis com comportamentos distintos têm testes próprios.
  Cada conclusão é sustentada por evidência; abrir uma atividade não chega.
- As gravações existentes corretas são aproveitadas. Lacunas podem ser preenchidas
  com síntese de voz PT-PT, após aprovação de amostras pelo professor. Exercícios de
  sons e letras exigem validação específica da pronúncia.
- Erros gerais que impeçam jogar ou concluir uma atividade são corrigidos, mesmo
  que afetem outras línguas. Melhorias visuais e novas funcionalidades ficam fora.
- O professor faz a revisão final das alterações linguísticas e pedagógicas e das
  amostras de voz, com uma lista concreta de elementos a rever.
- A versão Windows é testada, incluindo nos computadores da escola. Linux não
  substitui esta validação. O professor ou alguém na escola executa as verificações
  quando não houver acesso direto por parte do agente.

## Evidência e conclusão

O inventário estático gerado em `reports/` não certifica funcionamento.
Os resultados de execução vivem em `validation.csv`, com evidência detalhada em
`validation/<atividade>.md`. Os critérios e o procedimento estão em `validation.md`.
Resultados pendentes ou bloqueados não contam como aprovados.

O objetivo só termina quando todas as atividades passam os critérios aplicáveis,
o instalador offline passa em Windows 10 e a revisão do professor está concluída.

## Recursos e direitos

Registar a origem e a licença dos novos recursos distribuídos. A aprovação de
amostras de voz não substitui a verificação dos direitos de distribuição.
