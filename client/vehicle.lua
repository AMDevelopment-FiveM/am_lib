AM.Vehicle = AM.Vehicle or {}

function AM.Vehicle.Spawn(data)
    local model = type(data.model)=='string' and joaat(data.model) or data.model
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end
    local c=data.coords
    local veh=CreateVehicle(model,c.x,c.y,c.z,c.w or 0.0,data.networked ~= false,true)
    SetEntityAsMissionEntity(veh,true,true)
    if data.plate then SetVehicleNumberPlateText(veh,data.plate) end
    if data.warp then TaskWarpPedIntoVehicle(PlayerPedId(),veh,-1) end
    SetModelAsNoLongerNeeded(model)
    return veh
end

function AM.Vehicle.Delete(vehicle)
    if vehicle and DoesEntityExist(vehicle) then SetEntityAsMissionEntity(vehicle,true,true); DeleteVehicle(vehicle); return true end
    return false
end

exports('SpawnVehicle', AM.Vehicle.Spawn)
exports('DeleteVehicle', AM.Vehicle.Delete)
