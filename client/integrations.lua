AM.Garage = AM.Garage or {}
AM.Phone = AM.Phone or {}
AM.Doorlock = AM.Doorlock or {}
AM.Skillcheck = AM.Skillcheck or {}
AM.Minigame = AM.Minigame or {}
AM.Entity = AM.Entity or {}
AM.Network = AM.Network or {}
AM.Weapon = AM.Weapon or {}

function AM.Garage.Open(data)
    data = data or {}
    local bridge = AM.Bridges.garage or 'standalone'
    if bridge == 'qb_garages' then TriggerEvent('qb-garages:client:openGarage', data.type or 'job'); return true end
    if bridge == 'jg_advancedgarages' then TriggerEvent('jg-advancedgarages:client:open-garage', data.id or data.name); return true end
    TriggerEvent('am_lib:client:garageOpen', data)
    return true
end

function AM.Phone.Notify(data)
    data = data or {}
    local bridge = AM.Bridges.phone or 'standalone'
    if bridge == 'lb_phone' then
        return pcall(function() exports['lb-phone']:SendNotification({title=data.title or 'AM', content=data.description or data.message or '', icon=data.icon}) end)
    elseif bridge == 'qs_smartphone' then
        TriggerEvent('qs-smartphone:client:notify', data); return true
    end
    return AM.Notify and AM.Notify(data) or false
end

function AM.Doorlock.Set(id, locked)
    local bridge = AM.Bridges.doorlock or 'standalone'
    if bridge == 'ox_doorlock' then return pcall(function() exports.ox_doorlock:setDoorState(id, locked and 1 or 0) end) end
    if bridge == 'qb_doorlock' then TriggerServerEvent('qb-doorlock:server:updateState', id, locked, false, false, true, false); return true end
    TriggerEvent('am_lib:client:doorState', id, locked); return true
end

function AM.Skillcheck.Run(difficulty, inputs)
    local bridge = AM.Bridges.skillcheck or 'standalone'
    if bridge == 'ox_lib' and lib and lib.skillCheck then return lib.skillCheck(difficulty or {'easy'}, inputs) end
    TriggerEvent('am_lib:client:skillcheck', difficulty, inputs)
    return true
end

function AM.Minigame.Run(name, data)
    local bridge = AM.Bridges.minigame or 'standalone'
    if bridge == 'ps_ui' and exports['ps-ui'] then
        if name == 'circle' then local result=false; exports['ps-ui']:Circle(function(success) result=success end, data and data.circles or 2, data and data.time or 20); return result end
    end
    local p = promise.new()
    TriggerEvent('am_lib:client:minigame', name, data or {}, function(result) p:resolve(result == true) end)
    SetTimeout((data and data.timeout) or 15000, function() p:resolve(false) end)
    return Citizen.Await(p)
end

function AM.Entity.RequestControl(entity, timeout)
    timeout = timeout or 1500
    if not DoesEntityExist(entity) then return false end
    local start = GetGameTimer()
    NetworkRequestControlOfEntity(entity)
    while not NetworkHasControlOfEntity(entity) and GetGameTimer() - start < timeout do
        Wait(0); NetworkRequestControlOfEntity(entity)
    end
    return NetworkHasControlOfEntity(entity)
end

function AM.Entity.Delete(entity)
    if not DoesEntityExist(entity) then return true end
    AM.Entity.RequestControl(entity)
    SetEntityAsMissionEntity(entity, true, true)
    DeleteEntity(entity)
    return not DoesEntityExist(entity)
end

function AM.Network.ToNet(entity) return NetworkGetNetworkIdFromEntity(entity) end
function AM.Network.FromNet(netId) return NetworkGetEntityFromNetworkId(netId) end
function AM.Network.Exists(netId) return NetworkDoesNetworkIdExist(netId) end

function AM.Weapon.Give(ped, weapon, ammo, equip)
    local hash = type(weapon) == 'number' and weapon or joaat(weapon)
    GiveWeaponToPed(ped or PlayerPedId(), hash, ammo or 0, false, equip ~= false)
    return true
end
function AM.Weapon.Remove(ped, weapon)
    RemoveWeaponFromPed(ped or PlayerPedId(), type(weapon)=='number' and weapon or joaat(weapon)); return true
end
function AM.Weapon.Has(ped, weapon)
    return HasPedGotWeapon(ped or PlayerPedId(), type(weapon)=='number' and weapon or joaat(weapon), false)
end
