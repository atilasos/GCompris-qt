# Snapshots dos recursos dos testes QML nativos

O snapshot guarda o executável, `share/gcompris-qt` completo e `lib/qml` local
quando existe. Segue os symlinks, incluindo diretórios e ficheiros externos,
e grava ficheiros regulares independentes. Não contém ligações ao build.
Os RCC, catálogos e dados externos ficam identificados por SHA-256 no manifesto.

Criar uma vez, quando a compilação estiver estável:

```bash
python3 tools/native_qml_resources.py \
  --binary /caminho/build/bin/gcompris-qt \
  --output /caminho/privado/runtime-snapshot
```

O destino tem de ser novo e exterior aos recursos de origem. A criação compara
os hashes copiados e os hashes, destinos resolvidos e metadados dos ficheiros
originais antes/depois da cópia. Recusa alterações e remove a cópia incompleta.
Não modifiques um snapshot enquanto houver casos a usá-lo. A verificação deteta
ficheiros alterados, ausentes, adicionais ou ligados por symlink. O manifesto
é um registo de integridade, sem assinatura criptográfica.

Reutilizar em cada caso, mesmo depois de o build original mudar ou ser removido:

```bash
python3 tools/run-native-qml-case.py \
  --resource-snapshot /caminho/privado/runtime-snapshot \
  --activity click_on_letter \
  --qml-file src/activities/click_on_letter/ClickOnLetter.qml \
  --case tests/functional_letters/click_navigation.qml \
  --output /caminho/privado/navigation-1 \
  --start-level 3 --result-marker NATIVE_LETTERS_RESULT \
  --offline --timeout 45
```

O launcher verifica o manifesto antes e depois da execução. Copia o executável
e substitui apenas o RCC da atividade e o catálogo PT por versões privadas da
checkout indicada. Os restantes recursos apontam para o snapshot verificado.
Cada caso cria um perfil novo e um deployment privado junto à saída. Remove
esse deployment após sucesso; `--keep-deployment` conserva-o. As falhas conservam
o deployment. Nunca escreve no build da checkout nem no build de origem.

O modo offline usa uma imagem Docker local já existente, identificada pelo ID
real em `result.json`, independentemente do nome da tag. Mantém rede desativada,
raiz do host só para leitura e escrita nos diretórios privados de perfil/saída,
com `/tmp` temporário. Mounts explícitos só de leitura mantêm o deployment e
o snapshot visíveis mesmo quando ficam em `/tmp`, incluindo snapshots externos.
Os mounts do perfil e da saída conservam escrita. O chroot inicial da imagem entra no host; o GNU chroot do
host aplica `--userspec=UID:GID` antes de iniciar Qt. A verificação exige que os
ficheiros e symlinks de perfil/saída pertençam ao utilizador e grupo locais.
A limpeza normal propaga erros, incluindo erros de permissões.

Os resultados guardam hashes do manifesto, executável e recursos efetivos,
incluindo as duas substituições privadas. O snapshot não fixa as bibliotecas
Qt do sistema nem o código-fonte da checkout usado para preparar cada caso.

```bash
python3 -m unittest discover -s tests -p test_native_qml_resources.py
```

Os testes usam apenas ficheiros pequenos temporários. Verificam independência
após alterações na origem, adulteração e alterações durante a cópia.

Para verificar o percurso offline com recursos em `/tmp`, executa o caso Qt
normal curto nos dois modos. A pasta de evidência tem de ser nova e exterior
a `/tmp`; o verificador cria aí os logs e resultados e usa `/tmp` para o
snapshot externo e para a saída do caso com snapshot automático.

```bash
PYTHONDONTWRITEBYTECODE=1 python3 tests/native_qml_resources/check_tmp_offline.py \
  --binary /caminho/build/bin/gcompris-qt \
  --output /caminho/privado/verificacao-tmp
```

O verificador exige sucesso nos dois casos, dono local dos ficheiros e remoção
dos deployments. Remove o diretório temporário após sucesso. As falhas conservam
os ficheiros para inspeção e aparecem em `summary.json`. Usa a imagem Docker local
já instalada e mantém rede desativada.
