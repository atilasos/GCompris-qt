# Verificar uma atividade em PT-PT

1. Regista a versão da aplicação, o commit, a plataforma, a versão do sistema, o
   idioma escolhido e o formato dos recursos de áudio. Identifica o computador.
2. Seleciona português de Portugal. Confirma que a aplicação usa os recursos `pt`,
   distintos de `pt_BR`.
3. Lista os modos, configurações pedagógicas e níveis da atividade. Inspeciona todos
   os dados; não deduzas o número de níveis apenas a partir dos ficheiros JSON.
4. Inicia e conclui cada modo. Verifica respostas certas e erradas, ajuda, reinício,
   mudança de nível e regresso ao menu. Exercita os níveis cujo comportamento muda.
5. Verifica os textos e as vozes. Nos exercícios linguísticos, confirma o vocabulário,
   as respostas aceites e a pronúncia. Testa os caracteres aplicáveis, incluindo
   `á à â ã é ê í ó ô õ ú ç` e as maiúsculas, com teclado português.
6. Num perfil novo, instala o pacote com a rede desligada e executa as atividades.
   Confirma que áudio e imagens não dependem da cache de outra instalação.
7. Guarda evidência em `validation/<atividade>.md`. Identifica níveis, modos, passos,
   resultados, capturas ou logs e falhas conhecidas. Faz verificações em Linux e
   Windows 10. Regista separadamente a execução na escola.
8. Atualiza a linha da atividade em `validation.csv`. Usa `pending`, `blocked`,
   `failed`, `passed` ou `not-applicable`. Justifica cada `not-applicable` na evidência.
   Só marca `passed` quando os critérios aplicáveis estiverem demonstrados.

Para as colunas `linux`, `windows10`, `school_windows10` e `offline`, regista resultados
de execução. A coluna `linguistic_review` contém a aprovação do professor.
Em `evidence`, regista o caminho do ficheiro com os detalhes.

O inventário em `reports/` é gerado e pode ser substituído. Os resultados em
`validation.csv` e `validation/` são mantidos manualmente e nunca são gerados por
cima de verificações anteriores.
