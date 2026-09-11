AM = AM or {}
AM.Version = '1.4.0'
AM.Name = 'am_lib'
AM.Bridges = AM.Bridges or {}
AM.Modules = AM.Modules or {}
AM.Capabilities = AM.Capabilities or {}

function AM.RegisterCapability(name, supported)
    AM.Capabilities[name] = supported == true
end

function AM.Supports(name)
    return AM.Capabilities[name] == true
end

function AM.GetVersion()
    return AM.Version
end

exports('GetLib', function()
    return AM
end)

exports('GetVersion', function()
    return AM.Version
end)

exports('Supports', function(name)
    return AM.Supports(name)
end)
