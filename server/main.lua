local allowedStates = {
    [MZParkourStates.IDLE] = true,
    [MZParkourStates.SEARCHING] = true,
    [MZParkourStates.CLIMBING] = true,
    [MZParkourStates.DROPPING] = true
}

local rateWindows = {}

local function playerActionAllowed(source)
    local ok, allowed, result = pcall(function()
        return exports['mz_core']:CanPlayerPerformAction(source, 'emote.use')
    end)
    return ok and allowed == true and type(result) == 'table' and result.allowed == true
end

RegisterNetEvent('mz_parkour:server:setState', function(nextState)
    local sourceId = source
    if type(nextState) ~= 'string' or not allowedStates[nextState] then
        return
    end
    if nextState ~= MZParkourStates.IDLE and not playerActionAllowed(sourceId) then
        return
    end

    local now = GetGameTimer()
    local rate = rateWindows[sourceId]
    if not rate or now - rate.startedAt >= 1000 then
        rate = { startedAt = now, count = 0 }
        rateWindows[sourceId] = rate
    end

    rate.count = rate.count + 1
    if rate.count > 12 then
        return
    end

    local player = Player(sourceId)
    if player and player.state then
        player.state:set(MZParkourConfig.StateKey, nextState, true)
    end
end)

AddEventHandler('playerDropped', function()
    rateWindows[source] = nil
end)
