AM.Bridge.Register('inventory', 'ox_inventory', {
    resource = 'ox_inventory',
    add = function(src,item,count,metadata) return exports.ox_inventory:AddItem(src,item,count or 1,metadata) end,
    remove = function(src,item,count,metadata) return exports.ox_inventory:RemoveItem(src,item,count or 1,metadata) end,
    count = function(src,item,metadata) return exports.ox_inventory:Search(src,'count',item,metadata) or 0 end
})
