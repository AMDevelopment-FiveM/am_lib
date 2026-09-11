AM.Custom = AM.Custom or {}

function AM.Custom.RegisterBridge(category, name, adapter)
    return AM.Bridge.Register(category, name, adapter)
end

function AM.Custom.RegisterModule(name, data)
    return AM.Module.Register(name, data)
end
