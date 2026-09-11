AM.NPC = AM.NPC or {}

local registry = {}
local idCounter = 0

local function loadModel(model)
    local hash = type(model) == 'string' and joaat(model) or model
    if not hash or not IsModelInCdimage(hash) or not IsModelValid(hash) then
        if AM.Utils and AM.Utils.Debug then
            AM.Utils.Debug(('NPC model is invalid: %s'):format(tostring(model)))
        end
        return nil
    end

    RequestModel(hash)
    local timeout = GetGameTimer() + 10000
    while not HasModelLoaded(hash) do
        if GetGameTimer() >= timeout then
            if AM.Utils and AM.Utils.Debug then
                AM.Utils.Debug(('NPC model load timed out: %s'):format(tostring(model)))
            end
            return nil
        end
        Wait(50)
    end

    return hash
end

local function normalizeTargetOptions(id, options)
    local result = {}
    for i, option in ipairs(options or {}) do
        local opt = {}
        for k, v in pairs(option) do opt[k] = v end
        opt.name = opt.name or ('%s_target_%d'):format(id, i)
        result[#result + 1] = opt
    end
    return result
end

local function removeTarget(entry)
    if not entry or not entry.entity or not DoesEntityExist(entry.entity) then return end
    if not entry.targetNames or #entry.targetNames == 0 then return end

    if AM.Bridges and AM.Bridges.target == 'ox_target' and GetResourceState('ox_target') == 'started' then
        exports.ox_target:removeLocalEntity(entry.entity, entry.targetNames)
    elseif AM.Target then
        AM.Target.RemoveEntity(entry.entity)
    end
end

local function spawn(entry)
    if entry.entity and DoesEntityExist(entry.entity) then
        return entry.entity
    end

    local data = entry.data
    local hash = loadModel(data.model)
    if not hash then return nil end

    local c = data.coords
    local z = c.z - (data.zOffset ~= nil and data.zOffset or 1.0)
    local heading = c.w or data.heading or 0.0

    local ped = CreatePed(data.pedType or 4, hash, c.x, c.y, z, heading, false, true)
    if not ped or ped == 0 or not DoesEntityExist(ped) then
        SetModelAsNoLongerNeeded(hash)
        if AM.Utils and AM.Utils.Debug then
            AM.Utils.Debug(('CreatePed failed for NPC %s'):format(entry.id))
        end
        return nil
    end

    SetEntityAsMissionEntity(ped, true, true)
    SetEntityInvincible(ped, data.invincible ~= false)
    SetBlockingOfNonTemporaryEvents(ped, data.blockEvents ~= false)
    FreezeEntityPosition(ped, data.freeze ~= false)
    SetPedCanRagdoll(ped, data.ragdoll == true)

    if data.scenario then
        TaskStartScenarioInPlace(ped, data.scenario, 0, true)
    elseif data.animation and data.animation.dict and data.animation.clip then
        RequestAnimDict(data.animation.dict)
        local timeout = GetGameTimer() + 10000
        while not HasAnimDictLoaded(data.animation.dict) and GetGameTimer() < timeout do
            Wait(50)
        end
        if HasAnimDictLoaded(data.animation.dict) then
            TaskPlayAnim(
                ped,
                data.animation.dict,
                data.animation.clip,
                data.animation.blendIn or 8.0,
                data.animation.blendOut or -8.0,
                data.animation.duration or -1,
                data.animation.flag or 1,
                data.animation.rate or 0.0,
                false,
                false,
                false
            )
        end
    end

    entry.entity = ped

    if data.target and #data.target > 0 then
        local targetOptions = normalizeTargetOptions(entry.id, data.target)
        entry.targetNames = {}
        for _, option in ipairs(targetOptions) do
            entry.targetNames[#entry.targetNames + 1] = option.name
        end

        -- Same reliable pattern as the working AM Pawnshop NPC.
        if AM.Bridges and AM.Bridges.target == 'ox_target' and GetResourceState('ox_target') == 'started' then
            exports.ox_target:addLocalEntity(ped, targetOptions)
        elseif AM.Target then
            AM.Target.AddEntity(ped, targetOptions)
        end
    end

    SetModelAsNoLongerNeeded(hash)

    if AM.Utils and AM.Utils.Debug then
        AM.Utils.Debug(('Spawned NPC %s entity=%s'):format(entry.id, ped))
    end

    return ped
end

function AM.NPC.Create(data)
    assert(type(data) == 'table', 'AM.NPC.Create requires a data table')
    assert(data.model, 'AM.NPC.Create requires model')
    assert(data.coords, 'AM.NPC.Create requires coords')

    idCounter = idCounter + 1
    local id = data.id or ('am_npc_%d'):format(idCounter)

    -- Replace an NPC with the same id cleanly.
    if registry[id] then
        AM.NPC.Delete(id)
    end

    registry[id] = {
        id = id,
        data = data,
        entity = nil,
        targetNames = {}
    }

    spawn(registry[id])
    return id
end

function AM.NPC.Get(id)
    return registry[id] and registry[id].entity or nil
end

function AM.NPC.Exists(id)
    local entity = AM.NPC.Get(id)
    return entity ~= nil and DoesEntityExist(entity)
end

function AM.NPC.Delete(id)
    local entry = registry[id]
    if not entry then return false end

    if entry.entity and DoesEntityExist(entry.entity) then
        removeTarget(entry)
        SetEntityAsMissionEntity(entry.entity, true, true)
        DeletePed(entry.entity)
        if DoesEntityExist(entry.entity) then
            DeleteEntity(entry.entity)
        end
    end

    registry[id] = nil
    return true
end

CreateThread(function()
    while true do
        local player = PlayerPedId()
        local pcoords = GetEntityCoords(player)

        for _, entry in pairs(registry) do
            local c = entry.data.coords
            local dist = #(pcoords - vec3(c.x, c.y, c.z))
            local spawnDist = entry.data.spawnDistance or AMConfig.NPC.defaultSpawnDistance
            local despawnDist = entry.data.despawnDistance or AMConfig.NPC.defaultDespawnDistance

            if dist <= spawnDist then
                if not entry.entity or not DoesEntityExist(entry.entity) then
                    spawn(entry)
                end
            elseif dist > despawnDist and entry.entity and DoesEntityExist(entry.entity) then
                removeTarget(entry)
                DeletePed(entry.entity)
                if DoesEntityExist(entry.entity) then DeleteEntity(entry.entity) end
                entry.entity = nil
                entry.targetNames = {}
            end
        end

        Wait(AMConfig.NPC.respawnCheckMs or 3000)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    local ids = {}
    for id in pairs(registry) do ids[#ids + 1] = id end
    for _, id in ipairs(ids) do AM.NPC.Delete(id) end
end)

exports('CreateNPC', AM.NPC.Create)
exports('DeleteNPC', AM.NPC.Delete)
exports('GetNPC', AM.NPC.Get)
exports('DoesNPCExist', AM.NPC.Exists)
