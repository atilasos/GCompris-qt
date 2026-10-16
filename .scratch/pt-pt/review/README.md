# Revisão da integração PT-PT

Base original: `1d49ed1b397caca8243bd2b6bbc427a112219bda`.
Versão revista: `3961139094d5a690a637a75cc713d95d6342c0de`.
Os dois eixos foram revistos por agentes independentes, em paralelo.

## Standards

Três achados em [standards.md](standards.md): a preparação de vozes executaria
um binário de destino numa compilação cruzada Android; o mapa do tracker não
referencia duas tarefas resolvidas; os testes Windows repetem o ciclo de ambiente
e firewall, com dependência implícita entre os dois processos. O terceiro é
uma avaliação de duplicação, não uma regra obrigatória do repositório.

## Spec

Três achados em [spec.md](spec.md): falta a validação funcional completa dos
níveis e modos; o candidato Windows apenas lista as atividades; alterações
exclusivas nos novos recursos de voz não lançam o workflow. A validação humana
final, Windows10 e escola permanecem separadas destas lacunas corrigíveis.

## Encaminhamento

Um único implementador ficou responsável pelas correções técnicas da revisão.
A validação funcional continua na tarefa06, com lotes específicos de letras e
sequências, sem marcar as 203 atividades como concluídas pelo simples arranque.
A identificação de novos perfis Windows também está a ser corrigida: variáveis
APPDATA não garantem isolamento do QStandardPaths nessa plataforma.

Resultado: três achados por eixo. Em Standards, o maior problema é a execução
de um binário cruzado no host; em Spec, é a validação funcional ainda incompleta.
A especificação permanece aberta.
