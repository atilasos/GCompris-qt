# Ordenação PT-PT — provas em curso

Tarefa52. O instantâneo privado contém269 ficheiros físicos, sem dependências
de worktrees anteriores. O binário é lido do build principal e os RCC core e
das três atividades são recompilados exclusivamente na preparação privada.
O launcher compila também o PO atual para QM PT_PT privado.

A auditoria de dados usa lconvert real e verifica todos os16 conjuntos de
letras/números/frases (8/6/2 pastas, 8/8/20 níveis), intervalos de palavras,
alfabeto, cardinalidade e capacidade dos intervalos numéricos aleatórios.
O relatório contém o inventário SHA-256 das fontes das três atividades.

Reproduzir o vermelho com o catálogo original, sem alterar o checkout:

```sh
git show 4713dc58e:poqm/pt/gcompris_qt.po > /tmp/ordering-original.po
python3 tests/functional_ordering/audit_data.py --catalogue /tmp/ordering-original.po
python3 tests/functional_ordering/audit_data.py
```

Quatro frases violavam os intervalos explícitos dos comentários do conjunto.
Foram ajustadas e os objetivos PT passaram a «Até5/10 palavras», inclusivos.
O inventário nativo anterior preserva os sacos de palavras visíveis originais,
sem consultar a solução interna. O primeiro auditor vermelho é conservado.
As novas frases conservam tema e português europeu; revisão docente pendente.

As campanhas finais ainda estão em curso. Os recibos de pilotos ou diagnósticos
não constituem automaticamente aprovação de atividade. Windows, toque físico,
áudio/hardware e revisão pedagógica permanecem fora desta prova Linux offline.
