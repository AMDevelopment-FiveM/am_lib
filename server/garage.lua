AM.Garage = AM.Garage or {}
function AM.Garage.SetStored(owner, plate, stored, garage)
    local adapter = AM.Adapter and AM.Adapter.Get('garage')
    if adapter and adapter.SetStored then return adapter.SetStored(owner,plate,stored,garage) end
    TriggerEvent('am_lib:server:garageState', owner, plate, stored, garage)
    return true
end
function AM.Garage.GetVehicles(owner, garage)
    local adapter = AM.Adapter and AM.Adapter.Get('garage')
    if adapter and adapter.GetVehicles then return adapter.GetVehicles(owner,garage) end
    return {}
end
