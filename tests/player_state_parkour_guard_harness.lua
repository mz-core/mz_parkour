local function expect(condition, message)
    if not condition then error('[player_state_parkour_guard_harness] ' .. message, 2) end
end

MZParkourStates = { IDLE = 'idle', SEARCHING = 'searching', CLIMBING = 'climbing', DROPPING = 'dropping' }
local handlers = {}
RegisterNetEvent = function(name, handler) handlers[name] = handler end
AddEventHandler = function(name, handler) handlers[name] = handler end
GetGameTimer = function() return 1000 end

local currentState = 'alive'
local unavailable = false
exports = {
    mz_core = {
        CanPlayerPerformAction = function(_, _, action)
            expect(action == 'emote.use', 'acao canonica incorreta')
            if unavailable then error('state unavailable') end
            local allowed = currentState == 'alive'
            return allowed, { allowed = allowed }
        end
    }
}

local replicated = {}
Player = function(sourceId)
    return { state = { set = function(_, key, value, replicate)
        replicated[#replicated + 1] = { source = sourceId, key = key, value = value, replicate = replicate }
    end } }
end
MZParkourConfig = { StateKey = 'mz:parkourState' }

dofile('server/main.lua')
local setState = assert(handlers['mz_parkour:server:setState'])

local function invoke(sourceId, playerState, nextState)
    source = sourceId
    currentState = playerState
    local before = #replicated
    setState(nextState)
    return #replicated > before
end

expect(invoke(1, 'alive', 'searching'), 'alive foi negado')
expect(not invoke(2, 'downed', 'searching'), 'downed foi aceito')
expect(not invoke(3, 'dead', 'climbing'), 'dead foi aceito')
expect(not invoke(4, 'respawning', 'dropping'), 'respawning foi aceito')
expect(invoke(5, 'alive', 'searching'), 'alive apos transicao foi negado')
expect(invoke(6, 'dead', 'idle'), 'cleanup IDLE foi bloqueado')
unavailable = true
expect(not invoke(7, 'alive', 'searching'), 'estado indisponivel nao falhou fechado')
expect(invoke(8, 'dead', 'idle'), 'cleanup IDLE dependeu do snapshot')

local client = assert(io.open('client/utils.lua', 'rb'))
local clientSource = client:read('*a')
client:close()
expect(clientSource:find("CanLocalPlayerPerformAction('emote.use')", 1, true), 'guard local canonico ausente')

print('[player_state_parkour_guard_harness] PASS cases=8 cleanup_preserved=2')
