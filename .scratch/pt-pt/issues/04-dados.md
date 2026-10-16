# Verificar os dados pedagógicos de todos os níveis

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 01

## Aceitação

- Inspecionar dados em JSON, QML e recursos partilhados por atividades.
- Traçar a seleção efetiva de `pt_PT` e `pt` e os caminhos de fallback.
- Eliminar fallback involuntário para inglês ou português do Brasil.
- Verificar palavras, alfabeto, acentos, maiúsculas e respostas aceites.
- Manter progressão pedagógica e submeter as alterações ao professor.
- Validar os dados de todos os níveis automaticamente e confirmar a seleção real
  dos recursos em execução depois da tarefa 02.

## Pistas iniciais

`click_on_letter` e `gletters` não têm JSON `pt` equivalente aos defaults ingleses.
As variantes que reutilizam essas atividades também precisam de verificação.
A ausência de um ficheiro, isoladamente, não prova um defeito funcional.

## Comments

As capturas do professor confirmaram o fallback inglês em `grammar_classes` e
`grammar_analysis`. Acrescentados os conteúdos PT dos 15 níveis e 172 exercícios.
Oito testes verificam o carregamento, a estrutura, as soluções e a rejeição de
respostas erradas com o JavaScript original. Ver a tarefa 11 e `../grammar-review.md`.
As restantes atividades e a revisão linguística final continuam pendentes.


## Answer

Inspecionados os pontos de seleção de dados linguísticos e corrigidos os recursos
PT em falta nas letras e o fallback inglês na leitura. Acrescentados testes de
respostas, teclado acentuado, todos os níveis novos e vocabulário partilhado.
Passaram 15 testes JavaScript e os sete arranques Linux com recursos privados
compilados. Ver `../data/review.md` para alterações, limites e reprodução.

Esta conclusão cobre a implementação e a submissão para revisão; não aprova
linguisticamente todas as palavras nem certifica funcionalmente as 203 atividades.
Revisão do professor: tarefa 08. Execução interativa: tarefa 06. Áudio acentuado:
tarefa 05, com gravações já acrescentadas e audição final pendente. Windows: tarefas de entrega.
