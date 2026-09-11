AM.Bridge.Register('framework', 'esx', {
    resource = 'es_extended',
    getPlayer = function(src)
        if not IsDuplicityVersion() then return nil end
        return exports['es_extended']:getSharedObject().GetPlayerFromId(src)
    end,
    getClientData = function()
        if IsDuplicityVersion() then return nil end
        return exports['es_extended']:getSharedObject().GetPlayerData()
    end
})
