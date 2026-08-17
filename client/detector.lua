MZParkourDetector = MZParkourDetector or {}

local lastProbe = nil

local function makeProbe(ped, height)
    local cfg = MZParkourConfig.NativeTaskClimb.Probe
    local position = MZParkourUtils.FromNative(GetEntityCoords(ped))
    local forward = MZParkourUtils.Normalize2D(
        MZParkourUtils.FromNative(GetEntityForwardVector(ped))
    )

    local origin = MZParkourUtils.Add(position, MZParkourUtils.Vec(0.0, 0.0, height))
    origin = MZParkourUtils.Add(origin, MZParkourUtils.Mul(forward, cfg.ForwardStart))

    local finish = MZParkourUtils.Add(origin, MZParkourUtils.Mul(forward, cfg.ForwardEnd))
    local result = MZParkourShape.Capsule(origin, finish, cfg.Radius, ped)

    return {
        origin = origin,
        finish = finish,
        result = result
    }
end

function MZParkourDetector.FindClimbable(ped)
    local cfg = MZParkourConfig.NativeTaskClimb.Probe
    local chest = makeProbe(ped, cfg.ChestHeight)
    local upper = makeProbe(ped, cfg.UpperHeight)

    local result = chest.result and chest.result.hit and chest.result or nil
    if not result and upper.result and upper.result.hit then
        result = upper.result
    end

    lastProbe = {
        chest = chest,
        upper = upper,
        result = result
    }

    if not result then
        return nil, 'no_obstacle'
    end

    if math.abs(result.normal.z) > cfg.MaximumWallNormalZ then
        return nil, 'surface_too_sloped'
    end

    local pedPosition = MZParkourUtils.FromNative(GetEntityCoords(ped))
    if MZParkourUtils.Distance2D(pedPosition, result.position)
        > MZParkourConfig.NativeTaskClimb.ReachLength + 0.45 then
        return nil, 'outside_reach'
    end

    return {
        position = result.position,
        normal = result.normal,
        entity = result.entity,
        chest = chest,
        upper = upper
    }
end

function MZParkourDetector.GetLastProbe()
    return lastProbe
end
