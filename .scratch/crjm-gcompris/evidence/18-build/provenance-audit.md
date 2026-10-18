# Auditoria de origem e metadados

A integração criou implementações independentes dos oito jogos. Não importa
ficheiros React/TypeScript, motores CRJM, exercícios, textos ou imagens da
plataforma. As regras e sequências de jogadas são referências comportamentais.
A referência CRJM é `b206a7b4948673be935a5cb6a5a84df92d3ba6c2`, de atilasos.
Cada `ActivityInfo.qml` apresenta esse crédito na ajuda nativa. As notas
`PROVENANCE.md`/`ORIGIN.md` das atividades e os relatórios 02–17 registam as
fontes específicas. Os créditos de Gatos & Cães e Quelhas estão nos respetivos
`ActivityInfo.qml` e relatórios de entrega.

Os novos QML, ES modules, ícones e testes originais conservam
`GPL-3.0-or-later`; o novo CMake conserva `BSD-2-Clause`. A anotação REUSE
restrita às oito novas pastas e a `tests/crjm` usa `SPDX-FileCopyrightText:
NONE`: não atribui autoria humana inventada ao material gerado com IA. Não
substitui identificadores de licença já presentes. Alguns SVG tinham o marcador
SPDX seguido pelo resto do desenho na mesma linha, que o linter lia como parte
da expressão; a correção move apenas os comentários, preservando o desenho.
Documentos originais de proveniência e a serialização nova de Y recebem a
licença explicitamente registada na anotação. `reuse-red.log` mostra os erros
anteriores; `reuse-green.log` é vazio porque a verificação focal terminou com
código zero. A lista exata de ficheiros e comando está em `build-metadata.json`.
Não se afirma que a árvore histórica inteira passou REUSE.

Y conserva a distinção entre factos e expressão original: `board.mjs` regista
93 nós, 252 ligações e pertença aos três lados num formato novo. O DOCX e o
desenho de referência não foram incorporados. A licença da nova serialização
não relicencia o módulo TypeScript, os documentos ou a plataforma CRJM.
A origem e o hash do DOCX estão em `src/activities/y/PROVENANCE.md`.

O binário e os RCC são compilados do fork. A build completa conserva as
traduções, `rcc/data3` e o plugin Box2D da snapshot offline independente,
com hashes de origem e destino no manifesto. São componentes anteriores da
suite; as suas atribuições e termos originais continuam a aplicar-se. Qt e
bibliotecas multimédia são dependências instaladas nesta máquina e não foram
copiadas como novo código CRJM. Esta auditoria não concede direitos novos sobre
esses componentes nem constitui aprovação de distribuição do fork. Não houve
publicação, alteração de licença da plataforma CRJM ou contacto upstream.
