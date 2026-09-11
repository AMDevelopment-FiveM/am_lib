AM.Vehicle = AM.Vehicle or {}
function AM.Vehicle.SetFuel(vehicle, amount)
    amount=tonumber(amount) or 100.0; local bridge=AM.Bridges.fuel or 'native'
    if bridge=='ox_fuel' then return pcall(function() Entity(vehicle).state.fuel=amount end) end
    if bridge=='legacyfuel' and exports['LegacyFuel'] then return pcall(function() exports['LegacyFuel']:SetFuel(vehicle,amount) end) end
    SetVehicleFuelLevel(vehicle,amount+0.0); return true
end
function AM.Vehicle.GiveKeys(vehicle, plate)
    local bridge=AM.Bridges.keys or 'standalone'; plate=plate or GetVehicleNumberPlateText(vehicle)
    if bridge=='qb_vehiclekeys' then return pcall(function() TriggerEvent('vehiclekeys:client:SetOwner',plate) end) end
    if bridge=='renewed_vehiclekeys' then return pcall(function() exports['Renewed-Vehiclekeys']:addKey(plate) end) end
    return true
end
