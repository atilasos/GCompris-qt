# Produzir e verificar o instalador Windows 10 offline

Status: ready-for-agent
Progress: open
Type: task
Blocked by: 03, 04, 05, 06

## Aceitação

- Confirmar arquitetura dos PC da escola e compatibilidade do Qt escolhido com
  Windows 10 antes de fixar a toolchain.
- Usar o processo de empacotamento Windows existente quando adequado.
- Incluir atividades, traduções, vozes PT, imagens e restantes recursos necessários.
- Instalar num Windows 10 limpo, com rede desligada e sem cache anterior.
- Executar testes da aplicação empacotada e registar checksum do instalador,
  versões das dependências e instruções de instalação.

A prova da instalação offline depende de um ambiente Windows disponível.

O primeiro ensaio manual pode decorrer no computador pessoal Windows11 25H2
(compilação 26300.9711), confirmado pelo professor. A aceitação obrigatória em
Windows10 x64 será executada na escola; não inferir esse resultado do Windows11.
