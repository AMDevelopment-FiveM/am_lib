AM.Character = AM.Character or {}
AM.Character._requests = AM.Character._requests or {}
AM.Character._requestId = AM.Character._requestId or 0

function AM.Character.GetCharacters(callback)
    AM.Character._requestId = AM.Character._requestId + 1
    local id = AM.Character._requestId
    AM.Character._requests[id] = callback
    TriggerServerEvent('am_lib:character:requestList', id)
    return id
end

function AM.Character.Select(characterId, data)
    TriggerServerEvent('am_lib:character:select', characterId, data or {})
end

function AM.Character.Create(data)
    TriggerServerEvent('am_lib:character:create', data or {})
end

function AM.Character.Delete(characterId)
    TriggerServerEvent('am_lib:character:delete', characterId)
end

function AM.Character.Logout()
    TriggerServerEvent('am_lib:character:logout')
end

RegisterNetEvent('am_lib:character:responseList', function(requestId, characters)
    local cb = AM.Character._requests[requestId]
    AM.Character._requests[requestId] = nil
    if cb then cb(characters or {}) end
    TriggerEvent('am_lib:character:list', characters or {})
end)

exports('RequestCharacters', function(callback) return AM.Character.GetCharacters(callback) end)
exports('SelectCharacterClient', function(characterId, data) return AM.Character.Select(characterId, data) end)
exports('CreateCharacterClient', function(data) return AM.Character.Create(data) end)
exports('DeleteCharacterClient', function(characterId) return AM.Character.Delete(characterId) end)
