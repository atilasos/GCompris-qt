# Primeiro candidato Windows

[Actions 38807970526](https://github.com/atilasos/GCompris-qt/actions/runs/38807970526),
commit `dfc26b730790f2b0488864d6b9941c2c25109541`, concluído com sucesso.
Windows Server 2022, Qt6.10.2 MSVC2022 x64, OpenSSL fixado e NSIS3.11.
O teste mínimo real NSIS passou antes do empacotamento completo.

Os relatórios originais CI mostram oito arranques preparados e 203 instalados,
seis segundos cada, com firewall a bloquear a rede. As listas têm 203 IDs únicos;
os recursos e vozes PT completos passaram os hashes e foram registados.
Estes são testes de arranque, não de conclusão dos jogos.

O EXE foi descarregado e o SHA256 recalculado localmente em `download-verification.json`.
Local: `build/pt-pt/windows-candidate-38807970526/GCompris-PT-PT-Windows-x64-candidate.exe`.
O ZIP portátil e o seu checksum constam do CI; não foi descarregado nem
reverificado localmente. Os binários não são guardados no Git.

Este candidato antecede as correções posteriores de 17 handlers, ajuda e
consumidores NumPad. Serve para testar instalação/áudio no Windows11 25H2
26300.9711 do professor. Não é lançamento final nem validação Windows10/escola.
A execução manual pelo professor está pendente.
