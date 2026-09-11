AM.Bridge.Register('framework', 'qb', {
    resource = 'qb-core',
    getPlayer = function(src)
        if not IsDuplicityVersion() then return nil end
        return exports['qb-core']:GetCoreObject().Functions.GetPlayer(src)
    end,
    getClientData = function()
        if IsDuplicityVersion() then return nil end
        return exports['qb-core']:GetCoreObject().Functions.GetPlayerData()
    end
})
