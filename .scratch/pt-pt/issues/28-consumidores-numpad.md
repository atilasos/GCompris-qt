# Verificar uma tecla por entrada nos outros consumidores NumPad

Status: ready-for-agent
Progress: resolved
Type: task
Blocked by: 25

## Âmbito

Tens_complement_swap no modo input/calculadora, scalesboard e derivadas,
learn_decimals e guessnumber. Provar dígito, Backspace, decimal/vírgula PT
quando aplicável e preservação de Escape/Ctrl+W. Corrigir apenas defeitos
reproduzidos nos consumidores; não editar NumPad global nem Algebra (tarefa27).
Usar snapshots selados e RCC privados. Não equivale a concluir todos os níveis.

## Answer

Quatro defeitos de entrada reproduzidos e corrigidos nos consumidores, com
snapshot selado e RCC privado. Sete interfaces ativas verificadas, incluindo
as derivadas de balanças e as fases de resultado de adição/subtração decimal;
três controlos de fase inativa completam os dez casos. Escape/Ctrl+W continuam
a alcançar o menu; vírgula PT e normalização de ponto verificadas. Provas,
comando de repetição e limites em `../numpad-consumers/README.md` e
`../numpad-consumers/final/summary.json`. Não é conclusão de níveis nem prova
Windows. NumPad global e Algebra foram preservados.
