# Verificar bloqueio dos algarismos no teclado visual

Status: ready-for-agent
Progress: claimed
Type: task
Blocked by: 02, 25

## Âmbito

Inspeção encontrou guardas diferentes nas colunas0–4 e5–9 do NumPad.
Reproduzir por cliques Qt reais a garantia pública enableInput=false para
os dez algarismos e Backspace. O valor de entrada e enableInput são fixtures
ao nível do componente, não resolução de puzzles. Corrigir apenas se o teste
provar a violação. Provar também cliques normais quando enableInput=true.
Não declarar conclusão de atividades a partir deste contrato de componente.
