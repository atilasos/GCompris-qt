# Verificar as provas de Hanói na revisão testada

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 49, 51, 52

## Âmbito

Após a tarefa52 mudar mensagens de ordenação, o auditor de Hanói recusa as
seis provas antigas por comparar o hash do catálogo com o ficheiro atual.
Os recibos e mensagens de Hanói não mudaram. Reproduzir esta recusa e ligar
o auditor à revisão Git imutável das fontes/casos/catalogo realmente testados,
com informação explícita de âmbito histórico. Preservar os seis recibos e34
hashes, sem repetir Qt e sem transferir aprovação para código futuro.

Provar que a auditoria histórica passa com o catálogo atual diferente e
continua a rejeitar artefactos adulterados. Não criar framework ou migrar
outros validadores sem defeito demonstrado. Sem produção ou critérios globais.

## Answer

Recusa real capturada antes da correção; o mesmo auditor passa os seis
recibos depois de fixar as fontes à revisão testada. Três testes passam;
os 34 hashes de artefactos originais mantêm-se. Sem repetir Qt ou alterar
produção. Provas em `../hanoi-history55/README.md`.
