AM.Society = AM.Society or {}
function AM.Society.AddMoney(name,amount)
    amount=tonumber(amount) or 0
    if AM.Bridges.framework=='qb' or AM.Bridges.framework=='qbox' then
        if GetResourceState('qb-management')=='started' then return pcall(function() exports['qb-management']:AddMoney(name,amount) end) end
    elseif AM.Bridges.framework=='esx' then
        local ok=false; TriggerEvent('esx_addonaccount:getSharedAccount','society_'..name,function(acc) if acc then acc.addMoney(amount); ok=true end end); return ok
    end
    TriggerEvent('am_lib:server:societyAddMoney',name,amount); return true
end
function AM.Society.RemoveMoney(name,amount)
    amount=tonumber(amount) or 0
    if AM.Bridges.framework=='qb' or AM.Bridges.framework=='qbox' then if GetResourceState('qb-management')=='started' then return pcall(function() exports['qb-management']:RemoveMoney(name,amount) end) end end
    TriggerEvent('am_lib:server:societyRemoveMoney',name,amount); return true
end
