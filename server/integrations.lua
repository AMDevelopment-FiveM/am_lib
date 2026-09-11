AM.Garage = AM.Garage or {}
AM.Banking = AM.Banking or {}
AM.Boss = AM.Boss or {}
AM.Phone = AM.Phone or {}
AM.Crafting = AM.Crafting or {}
AM.Shop = AM.Shop or {}
AM.Adapter = AM.Adapter or { registry = {} }

function AM.Adapter.Register(category, name, implementation)
    assert(type(category)=='string' and type(name)=='string', 'invalid adapter id')
    assert(type(implementation)=='table', 'adapter implementation must be table')
    AM.Adapter.registry[category] = AM.Adapter.registry[category] or {}
    AM.Adapter.registry[category][name] = implementation
    return true
end
function AM.Adapter.Get(category, name)
    return AM.Adapter.registry[category] and AM.Adapter.registry[category][name or AM.Bridges[category]] or nil
end
function AM.Adapter.Call(category, method, ...)
    local adapter = AM.Adapter.Get(category)
    if not adapter or type(adapter[method]) ~= 'function' then return false, 'unsupported' end
    return adapter[method](...)
end

function AM.Banking.GetBalance(source, account)
    account = account or 'bank'
    if AM.Player and AM.Player.GetMoney then return AM.Player.GetMoney(source, account) end
    local player = AM.Player and AM.Player.Get(source)
    if player and player.Functions and player.Functions.GetMoney then return player.Functions.GetMoney(account) or 0 end
    if player and player.getAccount then local a=player.getAccount(account); return a and a.money or 0 end
    return 0
end
function AM.Banking.Add(source, account, amount, reason)
    if AM.Player and AM.Player.AddMoney then return AM.Player.AddMoney(source, account or 'bank', amount, reason) end
    return false
end
function AM.Banking.Remove(source, account, amount, reason)
    if AM.Player and AM.Player.RemoveMoney then return AM.Player.RemoveMoney(source, account or 'bank', amount, reason) end
    return false
end
function AM.Banking.Transfer(from, to, amount, account)
    amount = math.floor(tonumber(amount) or 0); if amount <= 0 then return false, 'invalid_amount' end
    account = account or 'bank'
    if not AM.Banking.Remove(from, account, amount, 'transfer') then return false, 'insufficient_funds' end
    if not AM.Banking.Add(to, account, amount, 'transfer') then AM.Banking.Add(from, account, amount, 'rollback'); return false, 'target_failed' end
    return true
end

function AM.Boss.Open(source, job)
    local bridge = AM.Bridges.boss or 'standalone'
    if bridge == 'qb_management' then TriggerClientEvent('qb-bossmenu:client:OpenMenu', source); return true end
    TriggerClientEvent('am_lib:client:bossOpen', source, job); return true
end

function AM.Phone.SendMessage(source, data)
    TriggerClientEvent('am_lib:client:phoneMessage', source, data or {})
    return true
end

function AM.Crafting.Register(id, recipes)
    AM.Crafting[id] = recipes or {}
    TriggerEvent('am_lib:server:craftingRegistered', id, recipes or {})
    return true
end
function AM.Crafting.CanCraft(source, recipe)
    if not recipe then return false end
    for item, count in pairs(recipe.ingredients or {}) do if not AM.Inventory.Has(source,item,count) then return false end end
    return true
end
function AM.Crafting.Craft(source, recipe)
    if not AM.Crafting.CanCraft(source, recipe) then return false, 'missing_ingredients' end
    for item,count in pairs(recipe.ingredients or {}) do AM.Inventory.Remove(source,item,count) end
    local out = recipe.output or {}; return AM.Inventory.Add(source,out.item,out.count or 1,out.metadata)
end

function AM.Shop.Register(id, data)
    AM.Shop[id] = data or {}
    TriggerEvent('am_lib:server:shopRegistered', id, data or {})
    return true
end
function AM.Shop.Buy(source, shopId, itemName, amount)
    local shop=AM.Shop[shopId]; if type(shop)~='table' then return false,'unknown_shop' end
    amount=math.max(1,math.floor(tonumber(amount) or 1))
    local selected
    for _,item in ipairs(shop.items or {}) do if item.name==itemName then selected=item break end end
    if not selected then return false,'unknown_item' end
    local total=(tonumber(selected.price) or 0)*amount
    if total>0 and not AM.Banking.Remove(source, selected.account or 'bank', total, 'shop:'..shopId) then return false,'insufficient_funds' end
    local ok=AM.Inventory.Add(source,itemName,amount,selected.metadata)
    if not ok and total>0 then AM.Banking.Add(source, selected.account or 'bank', total, 'shop_rollback:'..shopId) end
    return ok == true
end
