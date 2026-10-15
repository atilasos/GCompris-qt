# Verificar os dados pedagógicos de todos os níveis

Status: ready-for-agent
Progress: claimed
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
