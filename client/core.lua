AM.Client = AM.Client or {}
AM.Client.Cache = AM.Client.Cache or {}

local function detect(name, forced, candidates)
    if forced and forced ~= 'auto' then return forced end
    for _, entry in ipairs(candidates) do
        if AM.Utils.ResourceStarted(entry.resource) then return entry.id end
    end
    return 'standalone'
end

CreateThread(function()
    AM.Bridges.framework = detect('framework', AMConfig.Framework, {
        {id='qbox', resource='qbx_core'}, {id='qb', resource='qb-core'},
        {id='esx', resource='es_extended'}, {id='vrp', resource='vrp'}
    })
    AM.Bridges.target = detect('target', AMConfig.Target, {
        {id='ox_target', resource='ox_target'}, {id='qb_target', resource='qb-target'}
    })
    AM.Bridges.dispatch = detect('dispatch', AMConfig.Dispatch, {
        {id='ps_dispatch', resource='ps-dispatch'}, {id='cd_dispatch', resource='cd_dispatch'},
        {id='qs_dispatch', resource='qs-dispatch'}, {id='rcore_dispatch', resource='rcore_dispatch'}
    })
    AM.Bridges.fuel = detect('fuel', AMConfig.Fuel, {
        {id='ox_fuel', resource='ox_fuel'}, {id='legacyfuel', resource='LegacyFuel'}
    })
    AM.Bridges.keys = detect('keys', AMConfig.Keys, {
        {id='qb_vehiclekeys', resource='qb-vehiclekeys'}, {id='renewed_vehiclekeys', resource='Renewed-Vehiclekeys'}
    })
    AM.Bridges.garage = detect('garage', AMConfig.Garage, {{id='jg_advancedgarages', resource='jg-advancedgarages'}, {id='qb_garages', resource='qb-garages'}})
    AM.Bridges.phone = detect('phone', AMConfig.Phone, {{id='lb_phone', resource='lb-phone'}, {id='qs_smartphone', resource='qs-smartphone'}})
    AM.Bridges.doorlock = detect('doorlock', AMConfig.Doorlock, {{id='ox_doorlock', resource='ox_doorlock'}, {id='qb_doorlock', resource='qb-doorlock'}})
    AM.Bridges.skillcheck = detect('skillcheck', AMConfig.Skillcheck, {{id='ox_lib', resource='ox_lib'}})
    AM.Bridges.minigame = detect('minigame', AMConfig.Minigame, {{id='ps_ui', resource='ps-ui'}})
    if AMConfig.Multicharacter == 'auto' and AM.Bridges.framework == 'vrp' then
        AM.Bridges.multicharacter = 'vrp_core'
    else
        AM.Bridges.multicharacter = detect('multicharacter', AMConfig.Multicharacter, {
            {id='qb_multicharacter', resource='qb-multicharacter'},
            {id='esx_multicharacter', resource='esx_multicharacter'},
            {id='qbox_multicharacter', resource='qbx_core'}
        })
    end

    AM.Utils.Debug('Framework:', AM.Bridges.framework, 'Target:', AM.Bridges.target, 'Dispatch:', AM.Bridges.dispatch)
end)

RegisterCommand('amlibstatus', function()
    print(('^5[AM_LIB]^7 v%s'):format(AM.Version))
    for k,v in pairs(AM.Bridges) do print(('  %s: %s'):format(k, v)) end
end, false)
