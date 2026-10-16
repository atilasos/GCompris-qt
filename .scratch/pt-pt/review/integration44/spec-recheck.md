# Spec recheck — tarefa 44

Base: `45662f54da4b54b54dec1027decaf6d5d7eee02e`  
Head: `a9365de35641a6bf3a21385b35233d134c879b7d`  
Correção: `723bde268`; main inspecionado: `a8b47e642`.

**Findings acionáveis: 0.** O P1 anterior e a observação P2 foram corrigidos dentro do âmbito autorizado.

`complete_voices.py` escreve Contents e completion.json com `write_bytes(...encode("utf-8"))`; não existe tradução implícita LF→CRLF. A política fixa não foi relaxada. O codificador fixa também `newline="\n"` no manifesto futuro. A regressão simula a tradução Windows na fronteira de abertura de texto, inicia Contents em CRLF e verifica LF nas duas saídas. A prova suplementar de conclusão integral regista os mesmos 3484 bytes/hash Contents e 37210875 bytes/hash RCC fixados antes da correção.

As quatro regras exatas `.gitattributes` cobrem os textos identificados por hash bruto. Executei independentemente o teste de checkout Git real com `core.autocrlf=true` e `core.eol=crlf`: **1 teste passou**, com os quatro hashes exatos. A regra SVG existente mantém-se.

NOTICE passa a ser obrigatório para as substituições. RCC, Contents, cópias de proveniência e metadata são preparados/verificados no diretório temporário antes do primeiro `replace`; Contents é publicado por último. Os novos testes negativos verificam preservação de todos os bytes anteriores perante NOTICE ausente, falha de cópia, corrupção de cópia e erro de escrita da metadata. Isto cobre falhas de preparação; não constitui promessa de transação atómica entre todos os ficheiros perante interrupção durante os `replace`.

Executei ainda **9 testes Python** de nomes, aprovação exata, recusa de terceiro par/manipulação, política física e fronteira de codificação, todos aprovados. Inspecionei o código e os logs red/green/suite de 36 testes do suplemento; não voltei a executar a suite que compila utilitários Qt. As duas gravações aprovadas e as 32 anteriores mantêm a delimitação original.

Limites: sem Qt nativo, build, síntese, audição, instalação ou execução Windows nesta revisão. Os testes de terminações no Linux e checkout Git não substituem a validação do instalador na máquina Windows.
