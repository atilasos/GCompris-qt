# Preparar o pacote local de audição

Gera o ZIP a partir do manifesto e das 32 gravações novas já versionadas:

```bash
python3 tools/pt-pt-audio/package-review.py \
  --output build/pt-pt-audio-review/revisao-32-gravacoes.zip
```

Usa um nome novo se o ZIP já existir. `--source DIRETORIO` permite verificar
outra cópia de `resources/pt-pt-voices`. O script só usa `manifest.json`,
`NOTICE.md` e os 32 OGG enumerados no manifesto. Recusa hashes diferentes,
entradas repetidas, caminhos fora dos grupos previstos ou uma contagem diferente.
Não gera áudio e não precisa de dependências Python adicionais.

O resultado apresenta o caminho do ZIP e o seu SHA-256. O ZIP inclui:

- `index.html`, com os 32 players, transcrições e orientação em PT-PT;
- os 32 OGG originais, com os bytes verificados contra o manifesto;
- `manifest.json` e `NOTICE.md`, sem alterações;
- `review.csv`, com número, ficheiro, grupo, transcrição, estado e correções.

O CSV usa ponto e vírgula e UTF-8 com BOM para abertura no Excel do Windows.
Todas as linhas começam em `pending`. O script não marca nenhuma aprovação.

## Ouvir no Windows

1. Copia o ZIP para o computador de teste.
2. No Explorador de Ficheiros, escolhe **Extrair Tudo** e extrai o ZIP inteiro.
3. Abre `index.html` na pasta extraída com Edge, Chrome ou Firefox.
4. Ouve os clips pelos controlos de áudio e compara-os com as transcrições.
5. Anota o número, o nome do ficheiro, a passagem e a correção pretendida.
   Podes usar a coluna `correcoes` do CSV ou uma lista de correções.

Mantém a estrutura da pasta extraída. A página abre localmente, sem servidor
ou Internet. Abrir o HTML dentro do ZIP pode impedir o acesso aos OGG vizinhos.
A página não grava respostas. Guarda o CSV editado com outro nome antes de
recriar o pacote.

A autorização de geração continua distinta da audição final. Nos caracteres,
os clips nomeiam o acento ou a cedilha e não substituem fonemas. A revisão da
pronúncia e a aceitação pedagógica pertencem ao professor.

## Verificar o pacote

```bash
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover \
  -s tests -p test_pt_pt_audio_review_package.py
```

Os testes verificam os 36 membros exatos do ZIP, hashes dos OGG, preservação do
manifesto e aviso, 32 linhas pendentes, escaping de transcrições e rejeição de
entradas inválidas. Nenhuma gravação antiga, modelo ou WAV entra no pacote.

A verificação de browser disponível nesta máquina usa uma cópia extraída por
HTTP local. O Hub bloqueia navegação `file://`; esse modo e a reprodução sonora
no Windows continuam a ser verificados no computador do professor.
