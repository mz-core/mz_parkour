MZParkour = MZParkour or {}

local state = MZParkourStates.IDLE
local enabled = MZParkourConfig.Enabled
local busy = false
local lastTriggerAt = 0
local jumpDisabledUntil = 0
local lastCandidate = nil

local function publishState(nextState)
    state = nextState

    if LocalPlayer and LocalPlayer.state then
        LocalPlayer.state:set(MZParkourConfig.StateKey, nextState, false)
    end

    TriggerServerEvent('mz_parkour:server:setState', nextState)
end

local function stopGeneralEmote()
    if GetResourceState('mz_animations') ~= 'started' then
        return
    end

    pcall(function()
        exports['mz_animations']:Stop('parkour', true)
    end)
end

local function taskStarted(ped)
    return IsPedClimbing(ped)
        or GetIsTaskActive(ped, 50)
        or GetIsTaskActive(ped, 51)
end

local function waitForTaskStart(ped, timeoutMs)
    local deadline = GetGameTimer() + timeoutMs
    while GetGameTimer() < deadline do
        if taskStarted(ped) then
            return true
        end
        Wait(0)
    end
    return false
end

local function waitForTaskEnd(ped, maximumDurationMs)
    local deadline = GetGameTimer() + maximumDurationMs
    local observedTask = false

    while GetGameTimer() < deadline do
        local active = taskStarted(ped)
        observedTask = observedTask or active

        if observedTask and not active and not IsPedJumping(ped) then
            return
        end

        if MZParkourUtils.IsRestricted(ped) then
            return
        end

        Wait(30)
    end
end

function MZParkour.TryClimb(forceTest)
    local cfg = MZParkourConfig.NativeTaskClimb
    if not enabled or not cfg.Enabled or busy or state ~= MZParkourStates.IDLE then
        return false, 'busy_or_disabled'
    end

    local ped = PlayerPedId()
    if MZParkourUtils.IsRestricted(ped) then
        return false, 'restricted'
    end

    if not forceTest and cfg.RequireAirborne
        and not IsPedJumping(ped)
        and not IsPedFalling(ped) then
        return false, 'not_airborne'
    end

    local now = GetGameTimer()
    if not forceTest and now - lastTriggerAt < cfg.CooldownMs then
        return false, 'cooldown'
    end
    lastTriggerAt = now

    busy = true
    publishState(MZParkourStates.SEARCHING)

    local candidate, reason = MZParkourDetector.FindClimbable(ped)
    if not candidate then
        busy = false
        publishState(MZParkourStates.IDLE)
        return false, reason
    end

    lastCandidate = candidate
    stopGeneralEmote()

    if cfg.ClearTasksBeforeClimb then
        ClearPedTasksImmediately(ped)
    else
        ClearPedSecondaryTask(ped)
    end

    SetPedCanRagdoll(ped, false)
    publishState(MZParkourStates.CLIMBING)

    -- O segundo parâmetro é mantido em false; a documentação do native o
    -- marca como não utilizado.
    TaskClimb(ped, false)
    jumpDisabledUntil = GetGameTimer() + cfg.DisableJumpAfterTriggerMs

    local started = waitForTaskStart(ped, cfg.StartTimeoutMs)
    if started then
        waitForTaskEnd(ped, cfg.MaximumDurationMs)
    end

    SetPedCanRagdoll(ped, true)
    busy = false
    publishState(MZParkourStates.IDLE)

    return started, started and nil or 'native_task_not_started'
end

function MZParkour.TryGrab()
    return MZParkour.TryClimb(false)
end

function MZParkour.Release(reason)
    if state == MZParkourStates.IDLE and not busy then
        return false
    end

    local ped = PlayerPedId()
    ClearPedTasksImmediately(ped)
    SetPedCanRagdoll(ped, true)
    busy = false
    publishState(MZParkourStates.IDLE)

    if MZParkourConfig.Debug and reason then
        print(('[mz_parkour] tarefa cancelada: %s'):format(tostring(reason)))
    end

    return true
end

function MZParkour.SetEnabled(value)
    enabled = value == true
    if not enabled then
        MZParkour.Release('disabled')
    end
    return enabled
end

function MZParkour.IsEnabled()
    return enabled
end

function MZParkour.GetState()
    return state
end

function MZParkour.GetLedge()
    return lastCandidate
end

exports('TryGrab', function()
    return MZParkour.TryClimb(false)
end)

exports('ForceDrop', function()
    return MZParkour.Release('export')
end)

exports('SetEnabled', function(value)
    return MZParkour.SetEnabled(value)
end)

exports('IsEnabled', function()
    return MZParkour.IsEnabled()
end)

exports('GetState', function()
    return MZParkour.GetState()
end)

CreateThread(function()
    local control = MZParkourConfig.Controls.Trigger
    local debounce = MZParkourConfig.NativeTaskClimb.InputDebounceMs

    while true do
        if not enabled or busy then
            Wait(80)
        else
            local ped = PlayerPedId()
            local airborne = IsPedJumping(ped) or IsPedFalling(ped)

            if airborne and not MZParkourUtils.IsRestricted(ped) then
                if IsControlJustPressed(0, control) then
                    CreateThread(function()
                        local ok, reason = MZParkour.TryClimb(false)
                        if MZParkourConfig.Debug and not ok then
                            print(('[mz_parkour] tentativa recusada: %s'):format(tostring(reason)))
                        end
                    end)
                    Wait(debounce)
                else
                    Wait(0)
                end
            else
                Wait(80)
            end
        end
    end
end)

CreateThread(function()
    while true do
        if GetGameTimer() < jumpDisabledUntil then
            DisableControlAction(0, MZParkourConfig.Controls.Trigger, true)
            Wait(0)
        else
            Wait(40)
        end
    end
end)

CreateThread(function()
    while true do
        if state ~= MZParkourStates.IDLE and MZParkourUtils.IsRestricted(PlayerPedId()) then
            MZParkour.Release('restricted')
        end
        Wait(180)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    local ped = PlayerPedId()
    SetPedCanRagdoll(ped, true)

    if LocalPlayer and LocalPlayer.state then
        LocalPlayer.state:set(MZParkourConfig.StateKey, MZParkourStates.IDLE, false)
    end
end)
