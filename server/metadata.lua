AM.Metadata = AM.Metadata or {}
function AM.Metadata.Get(source,key)
    if AM.Bridges.framework=='qb' then local p=exports['qb-core']:GetCoreObject().Functions.GetPlayer(source); return p and p.PlayerData.metadata[key] end
    if AM.Bridges.framework=='qbox' and exports.qbx_core then local p=exports.qbx_core:GetPlayer(source); return p and p.PlayerData.metadata[key] end
    return nil
end
function AM.Metadata.Set(source,key,value)
    if AM.Bridges.framework=='qb' then local p=exports['qb-core']:GetCoreObject().Functions.GetPlayer(source); if p then p.Functions.SetMetaData(key,value); return true end end
    if AM.Bridges.framework=='qbox' and exports.qbx_core then return pcall(function() exports.qbx_core:SetMetadata(source,key,value) end) end
    TriggerEvent('am_lib:server:setMetadata',source,key,value); return false
end
