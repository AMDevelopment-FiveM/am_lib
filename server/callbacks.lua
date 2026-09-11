AM.Callback = AM.Callback or {}
AM.Callback.handlers = AM.Callback.handlers or {}

local function normalizeRegistration(a, b, c)
    -- Standard API: RegisterCallback(name, handler)
    if type(a) == 'string' and type(b) == 'function' then
        return a, b
    end

    -- Compatibility for wrappers that accidentally pass a leading self/table.
    if type(b) == 'string' and type(c) == 'function' then
        return b, c
    end

    -- Table API used by a number of FiveM callback wrappers.
    if type(a) == 'table' then
        local name = a.name or a.eventName or a.callbackName or a[1]
        local handler = a.handler or a.eventCallback or a.callback or a.cb or a[2]
        if type(name) == 'string' and type(handler) == 'function' then
            return name, handler
        end
    end

    return nil, nil
end

function AM.Callback.Register(a, b, c)
    local name, handler = normalizeRegistration(a, b, c)

    if type(name) ~= 'string' or name == '' then
        error('callback name must be a non-empty string', 2)
    end

    if type(handler) ~= 'function' then
        error(('callback %s handler must be a function'):format(name), 2)
    end

    AM.Callback.handlers[name] = handler
    return true
end

function AM.Callback.Exists(name)
    return type(AM.Callback.handlers[name]) == 'function'
end

function AM.Callback.Remove(name)
    AM.Callback.handlers[name] = nil
end

RegisterNetEvent('am_lib:server:callback', function(requestId, name, ...)
    local src = source

    if not AM.Server.Allow(src, 'callback:' .. tostring(name)) then
        return
    end

    local cb = AM.Callback.handlers[name]
    if type(cb) ~= 'function' then
        print(('^3[AM_LIB]^7 missing callback: %s (source %s)'):format(tostring(name), tostring(src)))
        TriggerClientEvent('am_lib:client:callback', src, requestId, nil, 'missing_callback')
        return
    end

    local result = table.pack(pcall(cb, src, ...))
    local ok = result[1]

    if not ok then
        print(('^1[AM_LIB]^7 callback %s failed: %s'):format(tostring(name), tostring(result[2])))
        TriggerClientEvent('am_lib:client:callback', src, requestId, nil, 'callback_error')
        return
    end

    table.remove(result, 1)
    TriggerClientEvent('am_lib:client:callback', src, requestId, table.unpack(result, 1, result.n - 1))
end)

exports('RegisterCallback', function(a, b, c)
    return AM.Callback.Register(a, b, c)
end)

exports('HasCallback', function(name)
    return AM.Callback.Exists(name)
end)

exports('RemoveCallback', function(name)
    return AM.Callback.Remove(name)
end)
