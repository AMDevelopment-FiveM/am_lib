AM.Bridge = AM.Bridge or { registry = {} }

function AM.Bridge.Register(category, name, adapter)
    assert(type(category) == 'string' and category ~= '', 'bridge category required')
    assert(type(name) == 'string' and name ~= '', 'bridge name required')
    assert(type(adapter) == 'table', 'bridge adapter must be a table')
    AM.Bridge.registry[category] = AM.Bridge.registry[category] or {}
    AM.Bridge.registry[category][name] = adapter
    return adapter
end

function AM.Bridge.Get(category, name)
    local group = AM.Bridge.registry[category]
    if not group then return nil end
    name = name or (AM.Bridges and AM.Bridges[category])
    return group[name]
end

function AM.Bridge.Call(category, method, ...)
    local adapter = AM.Bridge.Get(category)
    if not adapter then return nil, 'bridge_not_registered' end
    local fn = adapter[method]
    if type(fn) ~= 'function' then return nil, 'method_not_supported' end
    return fn(...)
end

function AM.Bridge.List(category)
    if category then return AM.Bridge.registry[category] or {} end
    return AM.Bridge.registry
end

exports('GetBridge', function(category, name) return AM.Bridge.Get(category, name) end)
