# Teste runtime — v0.2

1. Substitua a pasta `mz_parkour`.
2. Execute `restart mz_parkour`.
3. Corra e pule em direção a um muro, grade baixa, contêiner ou parapeito.
4. Enquanto ainda estiver no ar, aperte espaço novamente.
5. Use `/parkourdebug` para ver as duas sondas à frente.
6. Use `/parkourtest` parado diante do obstáculo para testar a tarefa diretamente.

## Ajuste principal

```lua
NativeTaskClimb = {
    ReachLength = 1.10
}
```

Aumente para `1.25` se estiver exigindo proximidade demais. Evite valores muito altos porque `TASK_CLIMB` pode selecionar outro objeto próximo.

## Resultado esperado

O personagem deve usar a animação nativa de vault/escalada do GTA V, sem ficar em pé congelado contra a parede. Essa tarefa normalmente sobe ou ultrapassa o obstáculo; ela não oferece por si só movimentação lateral permanente na borda.
