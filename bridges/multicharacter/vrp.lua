-- AM Lib vRP character bridge.
-- This is NOT a multicharacter resource. It exposes a common character API to
-- any multicharacter script and talks to vRP itself. For FlaxHosting vRP use
-- patches/flax_vrp/modules/am_multicharacter.lua inside the vRP resource.

local function vrpInterface()
    if not IsDuplicityVersion() then return nil end
    if not Proxy or not Proxy.getInterface then return nil end
    local ok, iface = pcall(Proxy.getInterface, 'vRP')
    return ok and iface or nil
end

local function callVrp(method, ...)
    local vRP = vrpInterface()
    local fn = vRP and vRP[method]
    if type(fn) ~= 'function' then return nil, 'vrp_character_patch_missing' end
    local args = {...}
    local ok, result, second = pcall(function()
        return fn(args)
    end)
    if not ok then
        if AMConfig.Debug then
            print(('^1[AM_LIB]^7 vRP character call %s failed: %s'):format(method, tostring(result)))
        end
        return nil, 'vrp_character_call_failed'
    end
    return result, second
end

local provider = {
    GetCharacters = function(source)
        return callVrp('amGetCharacters', source)
    end,
    Select = function(source, characterId, data)
        return callVrp('amSelectCharacter', source, characterId, data or {})
    end,
    Create = function(source, data)
        return callVrp('amCreateCharacter', source, data or {})
    end,
    Delete = function(source, characterId)
        return callVrp('amDeleteCharacter', source, characterId)
    end,
    Logout = function(source)
        return callVrp('amLogoutCharacter', source)
    end,
    GetSpawnData = function(source, characterId)
        return callVrp('amGetCharacterSpawnData', source, characterId)
    end
}

AM.Character.RegisterProvider('vrp_core', provider)
AM.Character.RegisterProvider('vrp_multicharacter', provider)
AM.Character.RegisterProvider('vrpm', provider)

-- Custom vRP forks may override the provider without editing AM Lib.
exports('RegisterVRPMulticharacter', function(name, customProvider)
    name = name or 'vrp_core'
    assert(type(customProvider) == 'table', 'custom vRP character provider must be a table')
    return AM.Character.RegisterProvider(name, customProvider)
end)
