AM.Bridge.Register('target', 'ox_target', {
    resource = 'ox_target',
    addEntity = function(entity, options) return exports.ox_target:addLocalEntity(entity, options) end,
    removeEntity = function(entity) return exports.ox_target:removeLocalEntity(entity) end
})
