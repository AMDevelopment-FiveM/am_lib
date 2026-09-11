AM.Bridge.Register('framework', 'qbox', {
    resource = 'qbx_core',
    getPlayer = function(src)
        if not IsDuplicityVersion() then return nil end
        return exports.qbx_core:GetPlayer(src)
    end,
    getClientData = function()
        if IsDuplicityVersion() then return nil end
        return exports.qbx_core:GetPlayerData()
    end
})
