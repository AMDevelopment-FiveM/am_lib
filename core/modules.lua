AM.Module = AM.Module or { registry = {} }

function AM.Module.Enabled(name)
    if not AMConfig or not AMConfig.Modules then return true end
    return AMConfig.Modules[name] ~= false
end

function AM.Module.Register(name, data)
    data = data or {}
    data.name = name
    data.enabled = AM.Module.Enabled(name)
    AM.Module.registry[name] = data
    AM.Modules[name] = data
    return data
end

function AM.Module.Get(name)
    return AM.Module.registry[name]
end

function AM.Module.List()
    return AM.Module.registry
end
