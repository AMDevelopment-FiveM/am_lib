AM.Character = AM.Character or {}

local function normalizeCharacter(char, index)
    char = char or {}
    local info = char.charinfo or char.character or char.identity or {}
    local money = char.money or {}
    local job = char.job or {}

    return {
        id = char.id or char.citizenid or char.identifier or char.user_id or char.characterId or char.charid or index,
        citizenid = char.citizenid,
        identifier = char.identifier,
        user_id = char.user_id,
        slot = char.slot or char.cid or char.characterId or char.charid or index,
        firstname = char.firstname or char.firstName or info.firstname or info.firstName or info.name or '',
        lastname = char.lastname or char.lastName or info.lastname or info.lastName or info.surname or '',
        name = char.name,
        birthdate = char.birthdate or char.dateofbirth or info.birthdate or info.dateofbirth,
        gender = char.gender or char.sex or info.gender or info.sex,
        nationality = char.nationality or info.nationality,
        phone = char.phone or char.phone_number or info.phone,
        job = type(job) == 'table' and (job.name or job.label) or job,
        jobLabel = type(job) == 'table' and job.label or nil,
        jobGrade = type(job) == 'table' and (job.grade and (job.grade.level or job.grade) or job.grade_level) or nil,
        cash = money.cash or char.cash,
        bank = money.bank or char.bank,
        metadata = char.metadata or {},
        raw = char
    }
end

local function normalizeList(list)
    local out = {}
    if type(list) ~= 'table' then return out end
    for k, char in pairs(list) do
        out[#out + 1] = normalizeCharacter(char, tonumber(k) or (#out + 1))
    end
    table.sort(out, function(a,b) return (tonumber(a.slot) or 999) < (tonumber(b.slot) or 999) end)
    return out
end

function AM.Character.GetCharacters(source)
    local result, err = AM.Character.Call('GetCharacters', source)
    if result ~= nil then return normalizeList(result), err end

    local adapter = AM.Bridge.Get('framework')
    if adapter and type(adapter.GetCharacters) == 'function' then
        return normalizeList(adapter.GetCharacters(source) or {})
    end
    return {}, err or 'not_supported'
end

function AM.Character.Select(source, characterId, data)
    local result, err = AM.Character.Call('Select', source, characterId, data or {})
    if result ~= nil then return result, err end
    local adapter = AM.Bridge.Get('framework')
    if adapter and type(adapter.SelectCharacter) == 'function' then
        return adapter.SelectCharacter(source, characterId, data or {})
    end
    return false, err or 'not_supported'
end

function AM.Character.Create(source, data)
    data = data or {}
    local result, err = AM.Character.Call('Create', source, data)
    if result ~= nil then return result, err end
    local adapter = AM.Bridge.Get('framework')
    if adapter and type(adapter.CreateCharacter) == 'function' then
        return adapter.CreateCharacter(source, data)
    end
    return false, err or 'not_supported'
end

function AM.Character.Delete(source, characterId)
    local result, err = AM.Character.Call('Delete', source, characterId)
    if result ~= nil then return result, err end
    local adapter = AM.Bridge.Get('framework')
    if adapter and type(adapter.DeleteCharacter) == 'function' then
        return adapter.DeleteCharacter(source, characterId)
    end
    return false, err or 'not_supported'
end

function AM.Character.Logout(source)
    local result, err = AM.Character.Call('Logout', source)
    if result ~= nil then return result, err end
    local adapter = AM.Bridge.Get('framework')
    if adapter and type(adapter.LogoutCharacter) == 'function' then
        return adapter.LogoutCharacter(source)
    end
    return false, err or 'not_supported'
end

function AM.Character.GetSpawnData(source, characterId)
    local result = AM.Character.Call('GetSpawnData', source, characterId)
    if result ~= nil then return result end
    local adapter = AM.Bridge.Get('framework')
    if adapter and type(adapter.GetSpawnData) == 'function' then
        return adapter.GetSpawnData(source, characterId)
    end
    return nil
end

exports('GetCharacters', function(source) return AM.Character.GetCharacters(source) end)
exports('SelectCharacter', function(source, characterId, data) return AM.Character.Select(source, characterId, data) end)
exports('CreateCharacter', function(source, data) return AM.Character.Create(source, data) end)
exports('DeleteCharacter', function(source, characterId) return AM.Character.Delete(source, characterId) end)
exports('LogoutCharacter', function(source) return AM.Character.Logout(source) end)
exports('GetCharacterSpawnData', function(source, characterId) return AM.Character.GetSpawnData(source, characterId) end)

RegisterNetEvent('am_lib:character:requestList', function(requestId)
    local src = source
    if not AM.Server.Allow(src, 'character:list') then return end
    TriggerClientEvent('am_lib:character:responseList', src, requestId, AM.Character.GetCharacters(src))
end)

RegisterNetEvent('am_lib:character:select', function(characterId, data)
    local src = source
    if not AM.Server.Allow(src, 'character:select') then return end
    local ok, err = AM.Character.Select(src, characterId, data)
    TriggerClientEvent('am_lib:character:selected', src, ok == true, err)
end)

RegisterNetEvent('am_lib:character:create', function(data)
    local src = source
    if not AM.Server.Allow(src, 'character:create') then return end
    local result, err = AM.Character.Create(src, data)
    TriggerClientEvent('am_lib:character:created', src, result, err)
end)

RegisterNetEvent('am_lib:character:delete', function(characterId)
    local src = source
    if not AM.Server.Allow(src, 'character:delete') then return end
    local ok, err = AM.Character.Delete(src, characterId)
    TriggerClientEvent('am_lib:character:deleted', src, ok == true, err)
end)

RegisterNetEvent('am_lib:character:logout', function()
    local src = source
    if not AM.Server.Allow(src, 'character:logout') then return end
    local ok, err = AM.Character.Logout(src)
    TriggerClientEvent('am_lib:character:loggedOut', src, ok == true, err)
end)
