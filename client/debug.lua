local debugEnabled = MZParkourConfig.Debug

local function drawPoint(position, red, green, blue, size)
    DrawMarker(
        28,
        position.x, position.y, position.z,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        size, size, size,
        red, green, blue, 180,
        false, false, 2, false, nil, nil, false
    )
end

local function drawProbe(probe, red, green, blue)
    if not probe then
        return
    end

    DrawLine(
        probe.origin.x, probe.origin.y, probe.origin.z,
        probe.finish.x, probe.finish.y, probe.finish.z,
        red, green, blue, 210
    )

    if probe.result and probe.result.hit then
        drawPoint(probe.result.position, red, green, blue, 0.09)
    end
end

RegisterCommand('parkour', function()
    local nextValue = not MZParkour.IsEnabled()
    MZParkour.SetEnabled(nextValue)
    MZParkourUtils.Notify(nextValue
        and MZParkourConfig.Notifications.Enabled
        or MZParkourConfig.Notifications.Disabled)
end, false)

RegisterCommand('parkourdebug', function()
    debugEnabled = not debugEnabled
    MZParkourUtils.Notify(debugEnabled
        and MZParkourConfig.Notifications.DebugOn
        or MZParkourConfig.Notifications.DebugOff)
end, false)

RegisterCommand('parkourtest', function()
    CreateThread(function()
        local ok, reason = MZParkour.TryClimb(true)
        if not ok then
            print(('[mz_parkour] teste falhou: %s'):format(tostring(reason)))
            MZParkourUtils.Notify(MZParkourConfig.Notifications.NoLedge)
        end
    end)
end, false)

CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/parkourdebug', 'Exibir sondas do TASK_CLIMB')
    TriggerEvent('chat:addSuggestion', '/parkourtest', 'Executar TASK_CLIMB no obstáculo à frente')
end)

CreateThread(function()
    while true do
        if not debugEnabled then
            Wait(300)
        else
            Wait(0)
            local probe = MZParkourDetector.GetLastProbe()
            if probe then
                drawProbe(probe.chest, 255, 90, 90)
                drawProbe(probe.upper, 90, 170, 255)
            end
        end
    end
end)
