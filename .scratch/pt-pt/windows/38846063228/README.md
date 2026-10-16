# Candidato Windows com os lotes 73 a 78

[Actions 38846063228](https://github.com/atilasos/GCompris-qt/actions/runs/38846063228),
fonte `9b001ee47d63ca70d16ec536892f8bc10c06553a`, concluiu com sucesso em
2026-10-16 às 04:08:38 UTC. O workflow foi iniciado manualmente após confirmar
que não havia um ensaio automático para esse commit. A origem exata da ausência
de arranque automático não foi demonstrada.

O ambiente CI foi Windows Server 2022, Qt 6.10.2 MSVC2022 x64 e NSIS 3.11.
Os relatórios originais confirmam o pacote, a instalação, oito arranques da
árvore preparada e 203 arranques da árvore instalada, seis segundos cada, sem
erros QML e com rede bloqueada. Todos os IDs esperados estão presentes. Isto
não demonstra conclusão dos níveis, audição ou comportamento em Windows 10.

O executável foi descarregado do artefacto 12024134219 e verificado localmente:
825768382 bytes, SHA-256
`e321eea8e9812f3b49f9f1509aec3d67f4e02d972c7959b2a26349b52a90d8f9`.
O tamanho, CRC do membro ZIP e SHA publicado coincidem. A sessão 99959 terminou
com código 0, saída `7255ec`; `download-verification.json` regista o resultado.
A extração prévia dos relatórios terminou com código 0 na sessão 50731,
saída `850247`. Os JSON da API estão na pasta irmã `ci-status/`.

Ficheiro local: `build/pt-pt/windows-candidate-38846063228/GCompris-PT-PT-Windows-x64-candidate.exe`.
O ZIP portátil consta do artefacto mas não foi descarregado nem reverificado
localmente. Os binários não são guardados no Git.

Este candidato inclui as correções dos lotes 73 a 78 e as 1610 vozes, incluindo
as 32 gravações aprovadas. Não inclui os lotes 79 a 82 posteriores à sua fonte,
nem resolve a investigação 83. Substitui o primeiro candidato para um teste
manual de instalação no Windows 11 pessoal; esse teste continua pendente.
Windows 10 da escola, hardware, audição e aceitação docente/global também
continuam pendentes. Não é um lançamento final.
