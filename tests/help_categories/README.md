# Categorias de ajuda: testes

```bash
python3 tests/help_categories/run.py \
  --binary /caminho/para/gcompris-qt --output /novo/diretorio
```

Requer Node, compilador C++, Qt6 Core/Qml e ferramentas rcc/lconvert/lrelease,
a aplicação com recursos offline e a imagem Docker já disponível. Cria um core.rcc
privado com as fontes atuais, um snapshot completo selado e dois casos Qt reais.
Não escreve no build principal. O novo módulo JS requer reconfigurar CMake num
build incremental da aplicação antes de compilar.

O runner verifica os 203 ActivityInfo e os 33 tokens, compila um QM PT, executa
o módulo real num QJSEngine com traduções e sem tradutor, depois abre a ajuda de
memória e labirinto com o botão real. O caso confirma o rodapé traduzido e os
identificadores de filtro inalterados; desloca a página por eventos de rato.
O snapshot impede que uma compilação concorrente invalide os RCC mapeados.

Para reproduzir o defeito anterior, acrescentar `--before-ref b19e37e07` e usar
outro diretório: os dois casos nativos devem falhar, mostrando os IDs em inglês.
O resto do ambiente e o caso são os mesmos; só DialogHelp vem dessa revisão.
A execução retorna código 1 para essas falhas esperadas.

`inventory.json` guarda IDs, rótulos e hashes das fontes. Os resultados nativos
identificam todos os recursos do snapshot; `summary.json` acrescenta hashes do
core.rcc, do QM e do módulo JS. A aceitação limita-se à apresentação das categorias;
Windows/escola, revisão docente e aprovação global dos jogos ficam separados.
