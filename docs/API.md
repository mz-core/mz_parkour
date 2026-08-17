# API pública

```lua
local ok = exports['mz_parkour']:TryGrab()
exports['mz_parkour']:ForceDrop()
exports['mz_parkour']:SetEnabled(false)

local enabled = exports['mz_parkour']:IsEnabled()
local state = exports['mz_parkour']:GetState()
```

Estado replicado:

```lua
Player(source).state['mz:parkour']
```

Valores possíveis:

```text
idle, searching, grabbing, hanging, shimmy, climbing, dropping
```
