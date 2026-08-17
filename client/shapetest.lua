MZParkourShape = MZParkourShape or {}

local function normalizeResult(status, hit, endCoords, surfaceNormal, entityHit)
    return {
        status = status,
        hit = hit == true or hit == 1,
        position = MZParkourUtils.FromNative(endCoords),
        normal = MZParkourUtils.FromNative(surfaceNormal),
        entity = entityHit or 0
    }
end

function MZParkourShape.Await(handle)
    local maxFrames = MZParkourConfig.NativeTaskClimb.Probe.ResultTimeoutFrames or 30

    for _ = 1, maxFrames do
        local status, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(handle)
        if status == 2 then
            return normalizeResult(status, hit, endCoords, surfaceNormal, entityHit)
        end
        if status == 0 then
            break
        end
        Wait(0)
    end

    return nil
end

function MZParkourShape.Capsule(from, to, radius, ignoreEntity, flags)
    local handle = StartShapeTestCapsule(
        from.x, from.y, from.z,
        to.x, to.y, to.z,
        radius,
        flags or MZParkourConfig.NativeTaskClimb.Probe.CollisionFlags,
        ignoreEntity or 0,
        7
    )

    return MZParkourShape.Await(handle)
end
