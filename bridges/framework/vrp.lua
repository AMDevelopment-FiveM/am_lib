AM.Bridge.Register('framework', 'vrp', {
    resource = 'vrp',
    getUserId = function(src)
        if not IsDuplicityVersion() then return nil end
        if not Proxy or not Proxy.getInterface then return nil end
        local vRP = Proxy.getInterface('vRP')
        return vRP and vRP.getUserId and vRP.getUserId({src}) or nil
    end
})
