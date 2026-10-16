# Cópia física do auditor puro

`portable-final.json` conserva duas execuções Docker completas, normal e `-O`,
ambas com retorno0. Em cada contentor os19 testes e a classificação dos três
finais/cinco negativos terminaram0. O wrapper terminou0 na sessão92004,
chunk93bfbd. `portable-observation.json` identifica a observação da conversa
como declaração do agente, sem assinatura autónoma da plataforma.

Usou-se a imagem Python3.12-slim pelo ID efetivamente observado
`sha256:a6e34c598f2467ed0e9a8d349809fcd8b5c603269512df273a0bb1784edc11b1`.
Código e oito recibos JSON foram copiados fisicamente, com hashes conferidos
no contentor. Não havia rede, Git, Qt ou árvore original. Não se instalou
qualquer dependência. O relatório conserva argv, stdout/stderr, retornos dos
processos e SHA256 de todos os Python copiados e de cada recibo bruto. Uma
verificação posterior confirmou que todos esses Python continuam iguais.

Esta é uma prova de portabilidade semântica do módulo. Recursos, PNGs, fontes
nativas, âncora e retornos da aplicação pertencem à cápsula do auditor principal.
Os JSON históricos foram copiados byte por byte, sem normalização ou alteração.

Reprodução em saída nova, com a imagem local disponível:

```sh
python3 tests/pattern_controls_audit/proof/portable_runner.py --records-root CAMINHO_DAS_PROVAS --output NOVO_RELATORIO.json
```

`portable-existing-output.json` conserva duas recusas reais, normal e `-O`, de
uma saída já existente, antes de consultar observações inexistentes. Os bytes
do relatório original permaneceram iguais. Não foram repetidas campanhas Qt.
