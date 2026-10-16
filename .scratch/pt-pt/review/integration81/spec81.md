# Revisão Spec independente — tarefa 81

Intervalo fixo `4011f8a0ee28f8a05de05b9b01fa0cb802469c2b...fbc9c80594a8942e779d62e07fb36cf5231a4acc`. Sem Qt/build ou alterações de main/provas.

**Sem achados acionáveis; confiança moderada/alta.**

Ticket81 exige «observar mãos, bola, alvo, barras de progresso, instruções e feedback desenhados», sem estados/limiares ocultos. Os casos usam coordenadas visíveis e eventos Qt reais. No apanha-bola verificam desvio lateral da tentativa incompleta e trajetória vertical do sucesso; no penálti esperam pela barra desenhada verde, verificam tentativa lenta vermelha, remate até à região da baliza e reposição por clique na bola. Não alteram relógios, velocidades ou progresso para produzir sucesso.

A spec30–35 exige «concluir os níveis e modos» e evidência. O auditor puro normal e `-O` confirmou 27 rotas/18 níveis únicos, 27 erros reparados e dois controlos; os dez testes passaram. As duas alternativas do apanha-bola percorrem os nove níveis. Alvos/botões do penálti distribuem nove combinações por nove níveis; o README distingue-as das 81 combinações cartesianas possíveis. Ajuda/Escape, foco por inputs, navegação/extremos, reinício parcial, teclado não suportado e menu estão sustentados; não há datasets/configuração/recarregar artificialmente inventados.

Ticket81 pede «caso idêntico vermelho e verde» e recursos/retornos preservados. Cinco pares byte-idênticos cobrem totais, ajuda e barras. Cápsulas de cinco fases, PO/QM, RCC reais/extrações instrumentadas, snapshot269 e recursos importados ligam-se aos recibos. A âncora literal recusa adulteração, vazio e reseal coerente; as transcrições externas identificam proveniência e permanecem separadas do retorno Qt/supervisor.

O original `penalty-complete` conserva Qt139/externos1 e não entra na campanha verde; `penalty-replay` tem o mesmo caso com saídas0. A tarefa83 aberta mantém a estabilidade por resolver. O fix das animações elimina barras antigas após navegação, sem reclamar resolver esse encerramento. GDB/journal não são promovidos a prova de causa ou aceitação.

As correções limitam-se a funcionalidade/português conforme spec27–29/39–40; não identifiquei scope creep. A spec43 diz «Linux não substitui esta validação»: Windows, dispositivos/toque real, audição, revisão docente, estabilidade e aceitação global continuam explicitamente pendentes.
