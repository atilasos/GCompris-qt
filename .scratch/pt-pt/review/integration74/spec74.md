# Revisão Spec independente — tarefa74

Intervalo fixo b993d329c6e4d6d967188bd1f9139516ce02ea64...cd1d763e8847b87db31d4993d46bfe4e58a0d2c9. Inspecionados spec/ticket, READMEs, produção, casos, oráculo e auditor. Sem Qt, alterações de mapa/CSV ou escrita de índices.

**Sem defeito funcional demonstrado; uma inconsistência documental menor.**

**[P3, confiança alta] Alinhar o critério Python-O com o contrato implementado.** Ticket74:23 exige “Falhar com Python -O”, enquanto `tests/functional_share/audit.py:11` usa `require()` ativo sob otimização e `test_audit.py:test_copied_original_passes_with_optimization` exige sucesso da prova válida com `-O`. Os testes confirmam rejeição das adulterações nas duas modalidades; a proteção pretendida está preservada. Atualizar o ticket para exigir verificações eficazes também com `-O`, ou rejeitar explicitamente essa opção se a recusa literal for requisito. Não é uma falha de validade das provas arquivadas.

Spec30–35 exige níveis/modos, respostas e evidência. A auditoria pura confirmou146 perguntas/30 percursos,30 erros reparados,47 perguntas com resto,544 redistribuições e14 recibos. Os14 testes passaram. A contagem não inclui duas perguntas extras dos controlos nem esgota sorteios aleatórios.

O solver conta SVG nas caixas, esgota o fornecimento visível e calcula quociente/resto. Não recebe soluções/contagens ocultas; cliques e arrastos conservam o total, com feedback e Bonus naturais. Controlos cobrem ajuda/Escape/foco, reinício parcial, seleção/configuração reabertas no mesmo processo, navegação e menu.

As duas correções cabem em spec27–29 e39–40: contexto português omitido e conversão duplicada das coordenadas de arrasto. Os pares nativos idênticos conservam vermelho/verde. Não há alteração artificial de relógios ou política pedagógica.

Âncoras Git conferem fases, casos, catálogo, recursos e snapshot269; sidecars pós-espera distinguem dois vermelhos externos1 dos12 verdes0, com Qt0 separado. Recursos originais/effective são identificados separadamente. Descodificação dos WAV não é audição nem nova aprovação de gravações. Limites Linux, Windows10, hardware, outras geometrias, áudio, professor e aceitação global203 estão explícitos; sem scope creep material.
