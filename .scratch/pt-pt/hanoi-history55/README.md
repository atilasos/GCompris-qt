# Auditoria histórica de Hanói

Depois das traduções de ordenação52, o auditor de Hanói falhou no hash do
catálogo atual, apesar de os seis recibos não mudarem. red.log conserva essa
recusa. green.log conserva seis casos/34 artefactos aprovados pelo auditor
ligado à revisão Git imutável realmente usada pelos casos. Nenhum teste Qt
foi repetido e nenhuma fonte de produção foi alterada.

```sh
python3 .scratch/pt-pt/functional-hanoi/audit.py
python3 -m unittest discover -s .scratch/pt-pt/hanoi-history55 -p test_audit.py -v
```

Os três testes com cópias temporárias confirmam os 34 hashes anteriores e a
recusa de SVG ou identidade de caso adulterados. Só o índice acrescenta a
revisão histórica explícita; os recibos, logs e capturas são os originais.
Auditar uma prova antiga não certifica alterações futuras da aplicação.
