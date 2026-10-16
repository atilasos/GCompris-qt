# Recheck Spec — menu após sucesso da tarefa 85

Intervalo fixo `ef7bf5ee37eabfb1d9ff674e0de4e202edae5c61...85b13d38a82bd873c8e4da1b3ed9ab51d7c0e494`. Sem Qt/build/push, alterações de main ou capturas.

**P2 anterior resolvido; sem novos achados acionáveis. Confiança alta.**

Ticket85:21–22 exige «menu durante atividade e após sucesso». O suplemento executa novamente os três percursos completos na fonte final58 e só depois chama `leaveAfterSuccess()`: eclusa após ida/volta e descarga, água após duche/Bonus/continuação, energia após três Bonus e corte natural por expiração do vento. Cada função usa Ctrl+W real e espera `depth=1`, `busy=false`, `currentItem.isMenu=true`; exporta esses valores e preserva `menu-after-success.png`. Não simula a página do menu nem conta o encerramento do processo como navegação.

`audit_menu.py` reaplica os oráculos físicos primários e exige os três menus estáveis. Confere o marcador Qt bruto, screenshots, caso exato, instrumentação do RCC, fonte/PO final e QM físico. Os três processos Qt, supervisor e capturador têm saídas0 observadas pós-espera e vinculadas aos mesmos recibos/casos. A ordem sucesso→menu é verificável no caso efetivamente instrumentado; a água também exporta timestamps ordenados.

O suplemento tem âncora literal própria e ligação à âncora primária. O diff não altera o arquivo original `functional-cycles`; os 18 recibos e 1010 artefactos históricos permanecem intactos. As três execuções novas são corretamente descritas como repetições de cobertura, sem aumentar os níveis distintos ou reatribuir fases aos recibos anteriores.

Comandos observados: `audit_menu.py`; `unittest discover` normal e `-O` — 17 testes passaram em cada modo; `portable.py --menu` — ambos os arquivos passaram normal/`-O` num contentor sem checkout original, Git ou Qt. Os testes rejeitam menu falso, transição ainda ativa e reseal coerente.

A spec35 pede «Cada conclusão é sustentada por evidência»: a lacuna agora tem prova própria, sem alterar produto nem acrescentar scope creep. O runtime completo continua somente inventariado fora dos recursos selecionados; Linux/software, audição, equipamento, Windows, revisão docente, estabilidade83 e aceitação global mantêm os limites anteriores.
