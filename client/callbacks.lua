AM.Callback = AM.Callback or {}
local pending,seq={},0
RegisterNetEvent('am_lib:client:callback',function(id,...)
    if pending[id] then pending[id]:resolve({...}); pending[id]=nil end
end)
function AM.Callback.Await(name,...)
    seq=seq+1
    local id=('%s:%s'):format(GetPlayerServerId(PlayerId()),seq)
    local p=promise.new(); pending[id]=p
    TriggerServerEvent('am_lib:server:callback',id,name,...)
    SetTimeout(AMConfig.Security.callbackTimeout,function() if pending[id] then pending[id]:resolve({nil,'timeout'}); pending[id]=nil end end)
    local result=Citizen.Await(p)
    return table.unpack(result)
end
exports('AwaitCallback',AM.Callback.Await)
