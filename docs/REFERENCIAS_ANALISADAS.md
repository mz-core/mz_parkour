# Referências analisadas

## `ParkourIV.dll`

O assembly enviado usa a ideia correta para o GTA V: durante o salto, detecta um obstáculo à frente e aciona a tarefa nativa de escalada do jogo. A versão 0.2 segue a mesma arquitetura sem reutilizar o binário do mod de single-player.

## `par.zip`

Os scripts `agu_parkour*.lua` apenas aplicam força, ragdoll, invencibilidade temporária e alterações globais de gravidade. Esse comportamento não produz agarrada de borda e pode causar voo, dessincronização e interferência em outros jogadores. Nada desse código foi incorporado.

## Mudança principal da versão 0.2

Foi removido do fluxo padrão:

- congelamento do ped;
- teleporte até a âncora;
- animação de borda incompatível;
- subida procedural em duas interpolações.

Agora o GTA V escolhe a animação e o movimento com `TASK_CLIMB`.
