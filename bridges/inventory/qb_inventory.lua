AM.Bridge.Register('inventory', 'qb_inventory', {
    resource = 'qb-inventory',
    add = function(src,item,count,metadata) return exports['qb-inventory']:AddItem(src,item,count or 1,false,metadata or false,'am_lib') end,
    remove = function(src,item,count) return exports['qb-inventory']:RemoveItem(src,item,count or 1,false,'am_lib') end
})
