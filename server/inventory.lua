AM.Inventory = AM.Inventory or {}
function AM.Inventory.Add(source,item,count,metadata)
    count=count or 1
    if AM.Bridges.inventory=='ox_inventory' then return exports.ox_inventory:AddItem(source,item,count,metadata) end
    if AM.Bridges.inventory=='qb_inventory' then return exports['qb-inventory']:AddItem(source,item,count,false,metadata or false,'am_lib') end
    local p=AM.Player.Get(source)
    if AM.Bridges.inventory=='esx' and p then p.addInventoryItem(item,count); return true end
    return false
end
function AM.Inventory.Remove(source,item,count,metadata)
    count=count or 1
    if AM.Bridges.inventory=='ox_inventory' then return exports.ox_inventory:RemoveItem(source,item,count,metadata) end
    if AM.Bridges.inventory=='qb_inventory' then return exports['qb-inventory']:RemoveItem(source,item,count,false,'am_lib') end
    local p=AM.Player.Get(source)
    if AM.Bridges.inventory=='esx' and p then p.removeInventoryItem(item,count); return true end
    return false
end
function AM.Inventory.Count(source,item,metadata)
    if AM.Bridges.inventory=='ox_inventory' then return exports.ox_inventory:Search(source,'count',item,metadata) or 0 end
    local p=AM.Player.Get(source)
    if AM.Bridges.inventory=='qb_inventory' and p and p.Functions.GetItemByName then local i=p.Functions.GetItemByName(item); return i and i.amount or 0 end
    if AM.Bridges.inventory=='esx' and p then local i=p.getInventoryItem(item); return i and i.count or 0 end
    return 0
end
function AM.Inventory.Has(source,item,count,metadata) return AM.Inventory.Count(source,item,metadata)>=(count or 1) end
function AM.Inventory.OpenStash(source,id,opts)
    opts=opts or {}
    if AM.Bridges.inventory=='ox_inventory' then
        exports.ox_inventory:RegisterStash(id,opts.label or id,opts.slots or 50,opts.weight or 100000,opts.owner,opts.groups,opts.coords)
        TriggerClientEvent('ox_inventory:openInventory',source,'stash',id); return true
    end
    return false
end
exports('AddItem',AM.Inventory.Add)
exports('RemoveItem',AM.Inventory.Remove)
exports('GetItemCount',AM.Inventory.Count)
exports('HasItem',AM.Inventory.Has)
exports('OpenStash',AM.Inventory.OpenStash)
