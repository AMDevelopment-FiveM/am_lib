AM.Server = AM.Server or {}
AM.Server.Rate = AM.Server.Rate or {}

local function detect(forced, candidates)
    if forced and forced ~= 'auto' then return forced end
    for _, entry in ipairs(candidates) do
        if AM.Utils.ResourceStarted(entry.resource) then return entry.id end
    end
    return 'standalone'
end

CreateThread(function()
    AM.Bridges.framework = detect(AMConfig.Framework, {
        {id='qbox', resource='qbx_core'}, {id='qb', resource='qb-core'},
        {id='esx', resource='es_extended'}, {id='vrp', resource='vrp'}
    })
    AM.Bridges.inventory = detect(AMConfig.Inventory, {
        {id='ox_inventory', resource='ox_inventory'}, {id='qb_inventory', resource='qb-inventory'},
        {id='vrp', resource='vrp'}, {id='esx', resource='es_extended'}
    })
    AM.Bridges.dispatch = detect(AMConfig.Dispatch, {
        {id='ps_dispatch', resource='ps-dispatch'}, {id='cd_dispatch', resource='cd_dispatch'},
        {id='qs_dispatch', resource='qs-dispatch'}, {id='rcore_dispatch', resource='rcore_dispatch'}
    })
    AM.Bridges.billing = detect(AMConfig.Billing, {
        {id='esx_billing', resource='esx_billing'}, {id='qb_management', resource='qb-management'}
    })
    AM.Bridges.fuel = detect(AMConfig.Fuel, {
        {id='ox_fuel', resource='ox_fuel'}, {id='legacyfuel', resource='LegacyFuel'}
    })
    AM.Bridges.keys = detect(AMConfig.Keys, {
        {id='qb_vehiclekeys', resource='qb-vehiclekeys'}, {id='renewed_vehiclekeys', resource='Renewed-Vehiclekeys'}
    })
    AM.Bridges.garage = detect(AMConfig.Garage, {
        {id='jg_advancedgarages', resource='jg-advancedgarages'}, {id='qb_garages', resource='qb-garages'}
    })
    AM.Bridges.phone = detect(AMConfig.Phone, {
        {id='lb_phone', resource='lb-phone'}, {id='qs_smartphone', resource='qs-smartphone'}
    })
    AM.Bridges.doorlock = detect(AMConfig.Doorlock, {
        {id='ox_doorlock', resource='ox_doorlock'}, {id='qb_doorlock', resource='qb-doorlock'}
    })
    AM.Bridges.boss = detect(AMConfig.Boss, {
        {id='qb_management', resource='qb-management'}, {id='esx_society', resource='esx_society'}
    })
    AM.Bridges.skillcheck = detect(AMConfig.Skillcheck, {
        {id='ox_lib', resource='ox_lib'}
    })
    AM.Bridges.minigame = detect(AMConfig.Minigame, {
        {id='ps_ui', resource='ps-ui'}
    })
    AM.RegisterCapability('inventory.metadata', AM.Bridges.inventory == 'ox_inventory' or AM.Bridges.inventory == 'qb_inventory')
    AM.RegisterCapability('inventory.stash', AM.Bridges.inventory ~= 'standalone')
    AM.RegisterCapability('vehicle.fuel', AM.Bridges.fuel ~= 'standalone')
    AM.RegisterCapability('vehicle.keys', AM.Bridges.keys ~= 'standalone')
    AM.RegisterCapability('billing', AM.Bridges.billing ~= 'standalone')
    AM.RegisterCapability('garage', AM.Bridges.garage ~= 'standalone')
    AM.RegisterCapability('phone', AM.Bridges.phone ~= 'standalone')
    AM.RegisterCapability('doorlock', AM.Bridges.doorlock ~= 'standalone')
    AM.RegisterCapability('boss', AM.Bridges.boss ~= 'standalone')
    AM.RegisterCapability('skillcheck', AM.Bridges.skillcheck ~= 'standalone')
    AM.RegisterCapability('minigame', AM.Bridges.minigame ~= 'standalone')
    print(('^5[AM_LIB]^7 v%s | framework=%s inventory=%s dispatch=%s'):format(AM.Version, AM.Bridges.framework, AM.Bridges.inventory, AM.Bridges.dispatch))
    if AMConfig.Multicharacter == 'auto' and AM.Bridges.framework == 'vrp' then
        -- vRP character support lives in the vRP core patch/provider, not in a
        -- separate multicharacter resource.
        AM.Bridges.multicharacter = 'vrp_core'
    else
        AM.Bridges.multicharacter = detect(AMConfig.Multicharacter, {
            {id='qb_multicharacter', resource='qb-multicharacter'},
            {id='esx_multicharacter', resource='esx_multicharacter'},
            {id='qbox_multicharacter', resource='qbx_core'}
        })
    end
    AM.RegisterCapability('multicharacter', AM.Bridges.multicharacter ~= 'standalone')
end)

function AM.Server.Allow(source, bucket)
    local now = os.time() * 1000
    local key = ('%s:%s'):format(source, bucket or 'default')
    local data = AM.Server.Rate[key]
    if not data or now - data.started > AMConfig.Security.rateLimitWindowMs then
        AM.Server.Rate[key] = {started=now,count=1}
        return true
    end
    data.count = data.count + 1
    return data.count <= AMConfig.Security.maxCallsPerWindow
end

AddEventHandler('playerDropped', function()
    local prefix = tostring(source)..':'
    for k in pairs(AM.Server.Rate) do if k:sub(1,#prefix)==prefix then AM.Server.Rate[k]=nil end end
end)
