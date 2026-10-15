# Registar a aprovação das 32 gravações

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 26

## Âmbito

O professor confirmou em 15 de outubro de 2026: «Ouvi as 32 e aprovo.»
Registar aprovação da pronúncia e dos textos dos 32 ficheiros do pacote ouvido,
identificados por hashes. Atualizar manifestos e metadados produzidos, sem
regenerar áudio nem alterar os 1578 originais. Se textos/bytes forem alterados
futuramente, a aprovação não se transfere automaticamente para esses recursos.
Preservar o ZIP ouvido e o respetivo checksum. A aprovação não substitui a
reprodução nas atividades/Windows nem a aceitação global do projeto.

## Answer

Aprovação registada por ficheiro em texts.json/manifest.json, com transcrição,
SHA256, data e declaração do professor. Os 32 recursos atuais foram comparados
com o ZIP ouvido, SHA256 cc48b858560d7f6496e2b2b76300940131ce558878554c53f52103e8b88e119e.
O ZIP original foi preservado.

Os produtores de metadados e CSV respeitam a aprovação; se um texto ou áudio
mudar, só esse ficheiro perde o estado aprovado. Testes reais dos comandos
reproduziram o estado incorreto antes da correção e passaram depois, incluindo
texto e bytes alterados. A suite completa passou 44 testes.

O RCC real completado foi refeito numa cópia privada: 1610 ficheiros, 1578
originais preservados e o mesmo SHA256 4887e4a8c7112e6b744829c82a3476a9f322a593173d17c3b7e369fad21528ee.
Nenhuma voz foi regenerada ou alterada. [Provas](../audio-review/approval-tests/),
[registo do professor](../audio-review/teacher-approval.json).
A tarefa05 permanece aberta apenas para os critérios de reprodução e aceitação
que não são substituídos por esta audição das 32 gravações.
