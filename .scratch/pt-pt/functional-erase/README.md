# Revelar imagens no Qt nativo

Os nove casos finais passaram no Linux PT-PT sem rede, com 269 recursos físicos
privados. Foram concluídos os seis níveis e seis imagens por nível em cada
atividade e nos modos automático e manual. São 36 percursos de nível, 216
imagens, 9 612 gestos válidos, 144 eventos negativos e 36 Bonus naturais.
Os três casos de controlos passaram reinício, ajuda, navegação, foco e menu.

| Atividade | Modos concluídos | Imagens | Gestos válidos |
| --- | --- | ---: | ---: |
| erase | automático e manual | 72 | 3 204 movimentos |
| erase_clic | automático e manual | 72 | 3 204 cliques |
| erase_2clic | automático e manual | 72 | 3 204 duplos cliques |

`full/*.process.json` distingue a saída do launcher da saída nativa e do
resultado das asserções Qt. Todos têm launcher_exit=0, native_exit=0 e
native_passed=true. O processo exterior aguardou os seis subprocessos e
terminou normalmente. Nenhuma campanha ficou dependente de uma sessão em
background depois da recolha.

## Oráculo visível

Os alvos vêm da geometria dos blocos desenhados, ordenados por coordenadas.
O caso verifica as grelhas de 5×5 e 8×8, os seus limites, ausência de
sobreposição, estado Image.Ready e opacidade antes e depois dos gestos.
Não chama enter/leave, blockKilled, funções de revelação ou validação; não
escreve máscara, contadores, Score, Bonus ou duração de animações.

Cada imagem carregada é observada no Qt original. Ao desaparecer toda a
máscara, o Score aumenta uma vez. O modo automático aguarda o fim natural da
animação. O modo manual aguarda esse mesmo fim, confirma que a imagem fica
revelada e só então prime OK. Cada último subnível produz Bonus e passa ao
nível seguinte, incluindo o retorno do sexto ao primeiro.

Há pares de capturas originais mascarada/revelada no primeiro subnível de
cada nível, em todas as seis campanhas. O auditor compara os píxeis nos 65%
superiores, dentro da máscara e fora do Score/Bar. Exige mudança acima de 8
níveis de luminância em mais de metade dessa região. As 36 comparações
passaram. Um teste negativo com capturas idênticas confirma a rejeição de
uma prova sem revelação efetiva.

No modo de movimento, sair antes dos 200 ms originais repõe o bloco. Espaço
e um clique direito fora da máscara não alteram o progresso. Clicar dentro
da máscara também pode entrar no bloco neste modo; não se afirma ignorar
essa entrada por haver um botão premido. Nos modos de clique/duplo clique,
movimento isolado, botões direito/central e duplo clique direito não apagam.
Um clique esquerdo isolado também não apaga no modo de duplo clique.

A configuração é operada pela interface real, guardada, lida por
ApplicationSettings e reaberta nos seis percursos. Os controlos reiniciam
uma imagem parcialmente revelada, verificam anterior/seguinte com retorno,
ajuda PT e novo gesto após a ajuda. Home foi usado em erase/erase_2clic e
Escape em erase_clic. Após fechar diálogos, o helper coloca o ponteiro fora
da máscara antes de iniciar um novo gesto de entrada.

## Correção e recursos

`probe` reproduz total público zero, privado seis e 25 blocos. A constante
interna não publicava o valor inicial. `probe-fixed` demonstra seis níveis
públicos/privados e imagem Ready. A única correção de produção declara o
valor no ActivityBase e usa uma leitura interna ligada ao mesmo valor.
Não se alteraram imagens, máscara ou lógica/tempos de jogo.

`data.json` inventaria 55 fontes, as seis grelhas, as 33 fotografias originais,
três máscaras e três WAV. Pillow descodificou integralmente as fotografias;
GStreamer descodificou os WAV para fakesink. Cada campanha carregou as 33
fotografias e as três máscaras no Qt. A campanha erase automática extraiu os
39 recursos pelo File original a partir do QRC; todos os bytes coincidem com
as fontes. Não se criaram recursos novos nem se alteraram créditos originais.

Os recibos mantêm o hash do catálogo usado em execução, da base 52be6feb5.
A integração posterior alterou cinco traduções de outras atividades.
`catalogue-compatibility.json` compara os dois catálogos pelo lconvert real
PT_PT e confirma as 203 mensagens referenciadas por core e pelas três
atividades inalteradas. Este número conta mensagens, não atividades aprovadas.
Uma mutação da tradução do título de clique para inglês é rejeitada pelo teste.
As provas antigas não foram reescritas para fingir outro catálogo executado.

## Repetir

Criar uma cópia de preparação privada a partir de recursos estáveis. O primeiro
comando apenas lê o build; `prepare.py` modifica exclusivamente a cópia passada
em --base e cria outro instantâneo físico selado. Nunca usar um build partilhado
ou recursos mapeados num processo nessa opção.

```sh
python3 tools/native_qml_resources.py --binary /BUILD/bin/gcompris-qt --output build/erase-staging
python3 tests/functional_erase/prepare.py --base build/erase-staging --output build/erase-snapshot
python3 tests/functional_erase/run.py --snapshot build/erase-snapshot --output /novo/resultado
python3 tests/functional_erase/audit_data.py
python3 tests/functional_erase/catalogue_compatibility.py
python3 tests/functional_erase/audit_evidence.py
python3 -m unittest discover -s tests/functional_erase -p test_audit.py
```

O runner aceita seleção por --activity/--mode. --levels 1 é só piloto;
o auditor final exige seis. O runner publica PID, início, fim e ambas as
saídas. Cada caso emite heartbeat por imagem. Para repetir controlos:

```sh
python3 tools/run-native-qml-case.py --resource-snapshot build/erase-snapshot --source-root . --activity erase --qml-file src/activities/erase/Erase.qml --case tests/functional_erase/controls.qml --output /novo/controlos-erase --offline --timeout 90 --result-marker NATIVE_ERASE_RESULT
```

Repetir a última chamada com erase_clic e erase_2clic. O auditor verifica
as pastas finais explícitas em full/ e controls-final/; novos resultados
precisam dos mesmos nomes num checkout sem essas pastas ou de adaptar essa
tabela. Pilotos e diagnósticos de instrumentação ficam fora da aceitação.

O teste usa eventos sintéticos entregues ao Qt original, numa janela 800×800.
Não certifica rato/toque físicos, outras resoluções/DPI ou Windows. Não existe
dispositivo áudio neste ambiente: SoundEffect não atingiu Ready/playing. Os
três WAV descodificados não demonstram reprodução ou audição. Áudio/hardware,
Windows e revisão docente permanecem pendentes, com aceitação global separada.
