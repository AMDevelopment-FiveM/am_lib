AM.Callback = AM.Callback or {}
AM.Callback.handlers = AM.Callback.handlers or {}
function AM.Callback.Register(name,cb) AM.Callback.handlers[name]=cb end
RegisterNetEvent('am_lib:server:callback',function(requestId,name,...)
    local src=source
    if not AM.Server.Allow(src,'callback:'..tostring(name)) then return end
    local cb=AM.Callback.handlers[name]
    if not cb then TriggerClientEvent('am_lib:client:callback',src,requestId,nil,'missing_callback'); return end
    local ok,a,b,c=pcall(cb,src,...)
    if ok then TriggerClientEvent('am_lib:client:callback',src,requestId,a,b,c) else
        print(('^1[AM_LIB]^7 callback %s failed: %s'):format(name,a))
        TriggerClientEvent('am_lib:client:callback',src,requestId,nil,'callback_error')
    end
end)
exports('RegisterCallback',AM.Callback.Register)
