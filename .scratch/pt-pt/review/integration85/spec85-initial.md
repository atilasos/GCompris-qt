# Revisão Spec independente — tarefa 85

Intervalo fixo `1efc489b2e1f0b8ddf83d26bf1fda48d0d0bceae...a20b4c2705bcfe9dfafd20b367c32b4cc600c397`; commits e diff revistos. Sem Qt/build/push ou alterações de provas.

**P2 — Falta verificar regresso ao menu após sucesso; confiança alta.** Ticket85:21–22 pede «menu durante atividade e após sucesso»; spec33–35 exige testes interativos e evidência para cada conclusão. Os três casos históricos `controls-{canal,water,energy}2/case.qml` só regressam ao menu durante movimento. `canal-complete2/case.qml:37` termina após descarregar os troncos; `water-pilot/case.qml:16` termina na observação `continued`; `energy-pilot/case.qml:24` termina após expiração natural do vento. Nenhum exerce o menu depois do sucesso. `tests/functional_cycles/audit.py:113–120` aceita somente `menuDuringMotion`, permitindo a entrega com esse requisito parcial.

Remédio: acrescentar provas dirigidas que concluam naturalmente cada objetivo e acionem o menu após o sucesso/continuação, confirmando a página real, saídas observadas e recursos físicos; exigir essa cobertura no auditor. Preservar os 18 recibos anteriores. Isto é uma lacuna funcional de verificação, não um defeito demonstrado no produto nem uma pendência humana.

Restantes requisitos examinados estão coerentes. A única produção alterada são oito traduções: terminologia eclusa/comportas/válvulas e objetivo da água sem prazo inexistente. Não há scope creep nem alteração do motor. Dois pares lexicais têm casos idênticos.

O planeador independente da eclusa usa altura/portas/posição; os casos verificam geometria, flutuação e bloqueios com inputs reais. Água observa dependências até duche; energia soma W desenhados, verifica consumidores, erro/recuperação e corte natural. Sem leitura de resposta oculta ou escrita de relógios/progresso. Percursos completos na fase canal-words e verificações finais de texto/controlos/recursos são explicitamente compostos.

Comandos observados: auditor puro, `unittest discover` normal e `-O` (13 testes cada), e `portable.py` Docker normal/`-O`: passaram. Confirmados 18 processos Qt0, 11 positivos, dois vermelhos lexicais, cinco diagnósticos do teste, 110 carregamentos/75 imagens e 21 descodificações. Fontes, RCC/QM e instrumentação físicos têm âncora literal. A escala histórica omitida não é inventada pelo auditor. Runtime incompleto, audição, equipamento, Windows, revisão docente, estabilidade83 e aceitação global mantêm limites honestos.
