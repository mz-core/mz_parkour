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
idle, searching, climbing, dropping
```

Esses são os estados do controlador `native_taskclimb` atual. Hanging e shimmy
não estão implementados no fluxo ativo.

Assets customizados e ferramentas pertencem a `mz_animations`; parkour é consumidor
e mantém ownership da mecânica/alinhamento. A dependência já existe no manifest.
Nenhum YCD do pipeline GTA IV foi ligado ao gameplay nesta fase. Consulte o
[contrato canônico](../../mz_docs/architecture/CUSTOM_ANIMATIONS.md) e o
[workspace source](../../mz_animations/tools/gta4_climb/README.md).
