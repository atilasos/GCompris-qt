# Relógio em português de Portugal

A atividade clockgame concluiu os dez níveis originais nos formatos de 12 e 24
horas. São 20 percursos, 100 perguntas, 100 respostas erradas rejeitadas e
corrigidas, 20 Bonus naturais e 245 gestos de ajuste nas duas campanhas.
Nenhum ficheiro de produção foi alterado.

O teste interpreta a instrução PT desenhada e calcula os ângulos do relógio de
forma independente. Move os ponteiros com gestos reais, separando primeiro
ponteiros sobrepostos quando necessário. Lê as propriedades de rotação dos
ponteiros efetivamente visíveis, sem targetH/targetM/targetS, currentH/currentM/
currentS, soluções do motor ou escrita em relógios/progresso. Não faz
reconhecimento de píxeis de cada resposta. Há vinte capturas finais por nível.

Os controlos verificam apoio digital visível/oculto, gravação e reabertura dos
formatos 12/24, reinício parcial, seleção persistida de seis datasets com
10→9→10 níveis, navegação circular, ajuda portuguesa, Escape, novo arrasto após
ajuda e Ctrl+W para o menu. A barra anima durante 1500 ms ao retirar o botão de
apoio; as primeiras duas tentativas de navegação do teste clicaram antes de
ela estabilizar. A terceira espera 1700 ms antes de obter as coordenadas e
passou sem alterações ao produto. Os pilotos e falhas anteriores ficam
preservados e não são somados às 100 perguntas finais.

Há quatro casos finais: twelve-complete, twenty-four-complete, controls3 e
resources. Cada um tem recibo Qt com saída 0, estado do lançador emitido pelo
supervisor depois de terminar com saída 0 e registo separado do retorno real da
ferramenta externa com saída 0. Os registos da ferramenta foram transcritos das
respostas observadas na conversa e identificam a sessão; não são recibos
emitidos pelo processo Qt.

A cápsula física contém 225 ficheiros da revisão fec529d1a e o runtime privado
foi copiado e conferido em 269 ficheiros. Os quinze recursos extraídos do QRC
correspondem aos originais, incluindo os SVG e dois efeitos WAV. Os WAV foram
apenas descodificados com GStreamer para fakesink. Não houve audição, dispositivo
de som, voz adicional ou transferência da aprovação das 32 gravações.

O auditor fixa o SHA do manifesto de captura e da cápsula, confere todos os
blobs finais, as respostas, os ângulos, os três retornos de processo, os recursos
e o inventário. Funciona com uma cópia das provas, sem o snapshot de execução
ou os caminhos antigos. Rejeita Python -O e adulteração com hashes recalculados.

    python3 tests/functional_clock/audit.py
    python3 -m unittest discover -s tests/functional_clock -p 'test_*.py'

Onze testes passaram. Esta é prova Linux delimitada. Windows 10, equipamento
físico, audição e aceitação linguística/pedagógica global continuam pendentes.
