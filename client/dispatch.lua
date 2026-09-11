AM.Dispatch = AM.Dispatch or {}
function AM.Dispatch.Send(data)
    local b=AM.Bridges.dispatch
    if b=='ps_dispatch' then TriggerServerEvent('ps-dispatch:server:notify', data); return true end
    if b=='cd_dispatch' then TriggerServerEvent('cd_dispatch:AddNotification', data); return true end
    if b=='qs_dispatch' then TriggerServerEvent('qs-dispatch:server:CreateDispatchCall', data); return true end
    if b=='rcore_dispatch' then TriggerServerEvent('rcore_dispatch:server:sendAlert', data); return true end
    TriggerServerEvent('am_lib:server:dispatchFallback', data); return true
end
exports('Dispatch', AM.Dispatch.Send)
RegisterNetEvent('am_lib:client:fallbackDispatch',function(data)
    AM.UI.Notify({title=data.title or data.code or 'Dispatch',description=data.description or 'Ny melding',type='inform',duration=7000})
    if data.coords and data.blip then
        local b=AddBlipForCoord(data.coords.x,data.coords.y,data.coords.z)
        SetBlipSprite(b,data.blip.sprite or 161); SetBlipScale(b,data.blip.scale or 1.0)
        BeginTextCommandSetBlipName('STRING'); AddTextComponentString(data.title or 'Dispatch'); EndTextCommandSetBlipName(b)
        SetTimeout((data.blip.duration or 60)*1000,function() if DoesBlipExist(b) then RemoveBlip(b) end end)
    end
end)
