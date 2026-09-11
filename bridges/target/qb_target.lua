AM.Bridge.Register('target', 'qb_target', {
    resource = 'qb-target',
    removeEntity = function(entity) return exports['qb-target']:RemoveTargetEntity(entity) end
})
