AM.Usable = AM.Usable or {}
function AM.Usable.Register(item,cb)
    if AM.Bridges.framework=='qb' then local QBCore=exports['qb-core']:GetCoreObject(); QBCore.Functions.CreateUseableItem(item,function(source,data) cb(source,data) end); return true end
    if AM.Bridges.framework=='qbox' and exports.qbx_core then exports.qbx_core:CreateUseableItem(item,function(source,data) cb(source,data) end); return true end
    if AM.Bridges.framework=='esx' then local ESX=exports['es_extended']:getSharedObject(); ESX.RegisterUsableItem(item,function(source) cb(source) end); return true end
    TriggerEvent('am_lib:server:registerUsable',item,cb); return false
end
