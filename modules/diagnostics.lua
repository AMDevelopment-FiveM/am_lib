AM.Diagnostics = AM.Diagnostics or {}

function AM.Diagnostics.Snapshot()
    local bridges, modules = {}, {}
    for k,v in pairs(AM.Bridges or {}) do bridges[k] = v end
    for name,data in pairs(AM.Module.List()) do modules[name] = data.enabled == true end
    return { version = AM.Version, bridges = bridges, modules = modules, capabilities = AM.Capabilities }
end

exports('Diagnostics', AM.Diagnostics.Snapshot)
