AM.Character = AM.Character or {}
AM.Character.Providers = AM.Character.Providers or {}

function AM.Character.RegisterProvider(name, provider)
    assert(type(name) == 'string' and name ~= '', 'character provider name required')
    assert(type(provider) == 'table', 'character provider must be a table')
    AM.Character.Providers[name] = provider
    return provider
end

function AM.Character.GetProvider(name)
    name = name or (AM.Bridges and AM.Bridges.multicharacter)
    return name and AM.Character.Providers[name] or nil
end

function AM.Character.HasProvider(name)
    return AM.Character.GetProvider(name) ~= nil
end

function AM.Character.Call(method, ...)
    local provider = AM.Character.GetProvider()
    if not provider then return nil, 'character_provider_not_registered' end
    local fn = provider[method]
    if type(fn) ~= 'function' then return nil, 'character_method_not_supported' end
    return fn(...)
end

exports('RegisterCharacterProvider', function(name, provider)
    return AM.Character.RegisterProvider(name, provider)
end)

exports('GetCharacterProvider', function(name)
    return AM.Character.GetProvider(name)
end)
