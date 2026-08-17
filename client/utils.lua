MZParkourUtils = MZParkourUtils or {}

function MZParkourUtils.Vec(x, y, z)
    return { x = x + 0.0, y = y + 0.0, z = z + 0.0 }
end

function MZParkourUtils.FromNative(value)
    return MZParkourUtils.Vec(value.x, value.y, value.z)
end

function MZParkourUtils.Add(a, b)
    return MZParkourUtils.Vec(a.x + b.x, a.y + b.y, a.z + b.z)
end

function MZParkourUtils.Sub(a, b)
    return MZParkourUtils.Vec(a.x - b.x, a.y - b.y, a.z - b.z)
end

function MZParkourUtils.Mul(a, scalar)
    return MZParkourUtils.Vec(a.x * scalar, a.y * scalar, a.z * scalar)
end

function MZParkourUtils.Dot2D(a, b)
    return a.x * b.x + a.y * b.y
end

function MZParkourUtils.Length2D(a)
    return math.sqrt(a.x * a.x + a.y * a.y)
end

function MZParkourUtils.Normalize2D(a)
    local length = MZParkourUtils.Length2D(a)
    if length < 0.0001 then
        return MZParkourUtils.Vec(0.0, 0.0, 0.0)
    end

    return MZParkourUtils.Vec(a.x / length, a.y / length, 0.0)
end

function MZParkourUtils.Distance2D(a, b)
    return MZParkourUtils.Length2D(MZParkourUtils.Sub(a, b))
end

function MZParkourUtils.Lerp(a, b, amount)
    return MZParkourUtils.Vec(
        a.x + (b.x - a.x) * amount,
        a.y + (b.y - a.y) * amount,
        a.z + (b.z - a.z) * amount
    )
end

function MZParkourUtils.Clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

function MZParkourUtils.SmoothStep(value)
    local t = MZParkourUtils.Clamp(value, 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)
end

function MZParkourUtils.HeadingFromNormal(normal)
    local facingX = -normal.x
    local facingY = -normal.y
    return GetHeadingFromVector_2d(facingX, facingY) + MZParkourConfig.Anchor.HeadingOffset
end

function MZParkourUtils.RightFromNormal(normal)
    return MZParkourUtils.Normalize2D(MZParkourUtils.Vec(normal.y, -normal.x, 0.0))
end

function MZParkourUtils.Notify(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(('%s: %s'):format(
        MZParkourConfig.Notifications.Prefix,
        tostring(message)
    ))
    EndTextCommandThefeedPostTicker(false, false)
end

function MZParkourUtils.IsRestricted(ped)
    if not DoesEntityExist(ped) or IsEntityDead(ped) or IsPedInAnyVehicle(ped, false) then
        return true
    end

    local state = LocalPlayer and LocalPlayer.state
    if state then
        for i = 1, #MZParkourConfig.RestrictedStateKeys do
            local key = MZParkourConfig.RestrictedStateKeys[i]
            if state[key] then
                return true
            end
        end
    end

    return false
end

function MZParkourUtils.SetEntityPosition(entity, position)
    SetEntityCoordsNoOffset(entity, position.x, position.y, position.z, false, false, false)
end

function MZParkourUtils.SmoothMove(entity, from, to, durationMs, heading)
    local started = GetGameTimer()
    local duration = math.max(1, durationMs)

    while true do
        local elapsed = GetGameTimer() - started
        local progress = MZParkourUtils.Clamp(elapsed / duration, 0.0, 1.0)
        local eased = MZParkourUtils.SmoothStep(progress)
        local position = MZParkourUtils.Lerp(from, to, eased)

        MZParkourUtils.SetEntityPosition(entity, position)
        if heading then
            SetEntityHeading(entity, heading)
        end

        if progress >= 1.0 then
            break
        end
        Wait(0)
    end
end
