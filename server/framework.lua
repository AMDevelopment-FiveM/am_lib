AM.Player = AM.Player or {}

local function vrpUserId(src)
    local ok, vRP = pcall(function() return Proxy and Proxy.getInterface and Proxy.getInterface('vRP') end)
    if ok and vRP and vRP.getUserId then return vRP.getUserId({src}) end
end

function AM.Player.Get(source)
    local b=AM.Bridges.framework
    if b=='esx' then return exports['es_extended']:getSharedObject().GetPlayerFromId(source) end
    if b=='qb' then return exports['qb-core']:GetCoreObject().Functions.GetPlayer(source) end
    if b=='qbox' then return exports.qbx_core:GetPlayer(source) end
    if b=='vrp' then return {source=source,user_id=vrpUserId(source)} end
    return {source=source}
end

function AM.Player.Identifier(source)
    local ids=GetPlayerIdentifiers(source)
    for _,id in ipairs(ids) do if id:sub(1,8)=='license:' then return id end end
    return ids[1]
end

function AM.Player.GetJob(source)
    local p=AM.Player.Get(source); if not p then return nil end
    if AM.Bridges.framework=='esx' then return p.job end
    if AM.Bridges.framework=='qb' or AM.Bridges.framework=='qbox' then return p.PlayerData and p.PlayerData.job end
    return nil
end

function AM.Player.HasJob(source, job, minGrade)
    local j=AM.Player.GetJob(source); if not j then return false end
    local grade=j.grade
    if type(grade)=='table' then grade=grade.level or grade.grade or 0 end
    return j.name==job and (not minGrade or (tonumber(grade) or 0)>=minGrade)
end

function AM.Player.AddMoney(source, account, amount)
    amount=tonumber(amount) or 0; if amount<=0 then return false end
    local p=AM.Player.Get(source); if not p then return false end
    if AM.Bridges.framework=='esx' then if account=='cash' then p.addMoney(amount) else p.addAccountMoney(account,amount) end return true end
    if AM.Bridges.framework=='qb' or AM.Bridges.framework=='qbox' then return p.Functions.AddMoney(account,amount,'am_lib') end
    return false
end

function AM.Player.RemoveMoney(source, account, amount)
    amount=tonumber(amount) or 0; if amount<=0 then return false end
    local p=AM.Player.Get(source); if not p then return false end
    if AM.Bridges.framework=='esx' then if account=='cash' then p.removeMoney(amount) else p.removeAccountMoney(account,amount) end return true end
    if AM.Bridges.framework=='qb' or AM.Bridges.framework=='qbox' then return p.Functions.RemoveMoney(account,amount,'am_lib') end
    return false
end

AM.Money={Add=AM.Player.AddMoney,Remove=AM.Player.RemoveMoney}
exports('GetPlayer', AM.Player.Get)
exports('GetIdentifier', AM.Player.Identifier)
exports('GetJob', AM.Player.GetJob)
exports('HasJob', AM.Player.HasJob)
exports('AddMoney', AM.Player.AddMoney)
exports('RemoveMoney', AM.Player.RemoveMoney)
