# Contratos públicos de níveis — tarefa 82

24 atividades ou variantes foram reproduzidas no Qt nativo: o seletor real
percorria 1 → 2 → 1, mas o total público permanecia zero. O caso idêntico após
a correção publica o total esperado e mantém a navegação real. Polygons tem
nove exercícios no modo tutorial: o seletor principal muda de exercício;
as páginas de apresentação usam um índice interno distinto. Neste caso também
faltava publicar o nível atual. Os modos livres não recebem níveis artificiais.

Os totais têm uma origem: a constante já existente, o tamanho dos dados ou a
configuração do modo. O arranque publica explicitamente as constantes; não
depende de um sinal de alteração que não ocorre na inicialização literal.

O arquivo físico `archive/` contém 24 pares vermelho/verde, dois controlos sem
seletor (damas a dois e polígonos livre), fontes históricas compactadas, casos,
RCC efetivamente substituídos e respetivos bytes extraídos pelo Qt, catálogo
compilado, imagens e recibos. As três atividades musicais fecham o aviso de som
através do botão desenhado antes da navegação. No controlo livre de polígonos,
o modo é preparado através da API pública de persistência e aplicado abrindo
as definições e premindo Gravar. Não são introduzidas respostas nos jogos.

Nos 50 casos preservados, o processo Qt terminou com 0. Nos 24 vermelhos, o
launcher e o supervisor terminaram com 1 porque o contrato falhou; nos 26
verdes/controlos ambos terminaram com 0. Estes retornos são observados após
esperar pelo processo, em ficheiros distintos. O caso vermelho de polígonos
regista também o nível público preso em zero enquanto a barra mostra 2.

Para verificar sem executar Qt ou Git:

```sh
python3 tests/public_levels/audit.py
python3 -O tests/public_levels/audit.py
python3 tests/public_levels/guard.py
python3 -m unittest discover -s tests/public_levels -p 'test_*.py'
```

O auditor requer os 24 pares completos, compara os casos idênticos, o log Qt,
os retornos separados, as fontes congeladas, a instrumentação exata, os recursos
extraídos e as imagens. Os testes rejeitam sete adulterações mesmo com o selo
externo recalculado, e executam uma cópia num contentor sem rede, árvore
original, Git ou ferramentas Qt. A guarda estática suplementa a prova nativa;
não certifica outras atividades nem substitui o Qt.

O snapshot independente local tem 269 ficheiros e cerca de 934 MB. O manifesto
completo está preservado, mas a cápsula compacta não inclui todos os seus bytes
(por exemplo, o grande pacote full-ogg). A cópia portátil verifica as observações
e os bytes físicos selecionados; não consegue repetir a execução Qt sem voltar
a disponibilizar o runtime e os recursos completos. RCC partilhados necessários
aos imports da fonte são preservados fisicamente.

Exclusões: galo e penálti pertencem às tarefas 80/81; ballcatch tem reprodução
própria na 81; maze já publica o total no arranque; solar_system atribui o total
na carga de configuração; oware e os modos de damas/galo a dois não oferecem
seletor. O template não é uma atividade distribuída. O relatório estático
original permanece em `public-level-candidates.md`.

A verificação cobre metadados públicos e navegação em Linux/software/offline.
Não acrescenta jogos concluídos nem aprova CSV, Windows, dispositivos, áudio,
pronúncia ou revisão docente. Não foi reconstruído o build principal.

## Correções do verificador e executor após a revisão

O auditor fixa no código externo o SHA-256 do `archive/sealed.json` histórico
(`39e855e2bd740c70bc6e02f3953cae9babd078ebcd5d5c417764e73353c82f5d`).
Uma substituição coerente do PO verde, cápsula, índices, recibos, estados e selo
é rejeitada, mesmo que todos os hashes internos sejam recalculados.

O executor recusa uma saída existente antes de criar casos, abrir logs ou
invocar processos. Usa criação exclusiva para logs e estados; uma recusa do
supervisor com código 2 não produz um estado sobre um recibo preexistente.
O teste verifica que todos os bytes anteriores permanecem inalterados.

Os sete testes passam em Python normal e com `-O`. A cópia isolada também
verifica o arquivo original, rejeita a adulteração coerente e executa a recusa
sobre a saída existente em ambos os modos. Nenhuma campanha Qt foi repetida:
os índices, cápsulas, recibos, recursos e observações anteriores conservam os
bytes e a fase histórica. A nova verificação está em
`review-fixes-verification.json`; `verification.json` continua a registar os
comandos da campanha original.
