# Standards — lote32

Comparação: `git diff f5f858e8a...19c8c0826a120383648362fead8dec732bdbc3a9`. Fontes: AGENTS.md, README.md, convenções locais e heurísticas Fowler da skill code-review.

Sem violações documentadas ou smells relevantes encontrados. A alteração em ActivityInfo.qml corrige uma etiqueta de lista HTML no mesmo padrão das entradas adjacentes, preservando a separação das mensagens traduzíveis.

O caso funcional calcula tentativas a partir do intervalo e das dicas visíveis, com limites explícitos de tentativas, sem ler o número secreto. Os nomes descrevem o domínio e os registos conservam os números tentados e as dicas observadas. O helper de entrada concentra a seleção entre teclado físico e virtual; não há switches repetidos nem abstrações especulativas.

O teste dos controlos segue a estrutura já adotada pelos testes nativos deste fork, verifica o fragmento HTML concreto que falhava e recolhe as capturas reais de ajuda/menu. A navegação pela árvore visual está confinada ao adaptador de teste; não acrescenta dependências aos módulos de produção. O pequeno objeto de títulos para esta atividade segue o padrão local e não justifica uma abstração nova.

As provas e o índice delimitam comandos, recursos e resultados. Não foi encontrada mudança alheia à tarefa nem contribuição upstream que contrarie a regra do README.

Resultado: zero findings Standards.
