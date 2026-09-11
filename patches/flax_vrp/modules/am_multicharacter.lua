-- AM Development - FlaxHosting vRP character compatibility patch
-- Put this file in: resources/[vrp]/vrp/modules/am_multicharacter.lua
-- Then load it directly after base.lua in vrp/__resource.lua.
-- This is only a vRP CORE PATCH. It has no UI and is not a multicharacter script.

local function accountIdentifier(source)
    local ids = GetPlayerIdentifiers(source)
    local first = ids and ids[1] or nil
    if ids then
        for _, id in ipairs(ids) do
            if id:sub(1, 8) == 'license:' then return id end
        end
        for _, id in ipairs(ids) do
            if id:sub(1, 6) == 'steam:' then return id end
        end
    end
    return first
end

local function awaitQuery(query, params)
    if MySQL and MySQL.query and MySQL.query.await then
        return MySQL.query.await(query, params or {})
    end
    local p = promise.new()
    MySQL.Async.fetchAll(query, params or {}, function(rows) p:resolve(rows or {}) end)
    return Citizen.Await(p)
end

local function awaitInsert(query, params)
    if MySQL and MySQL.insert and MySQL.insert.await then
        return MySQL.insert.await(query, params or {})
    end
    local p = promise.new()
    if MySQL.Async.insert then
        MySQL.Async.insert(query, params or {}, function(id) p:resolve(id) end)
    else
        MySQL.Async.execute(query, params or {}, function()
            local rows = awaitQuery('SELECT LAST_INSERT_ID() AS id')
            p:resolve(rows[1] and rows[1].id or nil)
        end)
    end
    return Citizen.Await(p)
end

local function awaitExec(query, params)
    if MySQL and MySQL.update and MySQL.update.await then
        return MySQL.update.await(query, params or {})
    end
    local p = promise.new()
    MySQL.Async.execute(query, params or {}, function(changed) p:resolve(changed or 0) end)
    return Citizen.Await(p)
end

local function ensureTable()
    awaitExec([[
        CREATE TABLE IF NOT EXISTS `am_vrp_characters` (
          `account_identifier` varchar(255) NOT NULL,
          `user_id` int(11) NOT NULL,
          `slot` int(11) NOT NULL DEFAULT 1,
          `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
          PRIMARY KEY (`account_identifier`, `user_id`),
          UNIQUE KEY `am_vrp_account_slot` (`account_identifier`, `slot`),
          KEY `am_vrp_user_id` (`user_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ]])
end

CreateThread(ensureTable)

local function getCurrentUserId(source)
    return vRP.getUserId(source)
end

local function ensurePrimaryCharacter(source)
    local account = accountIdentifier(source)
    local user_id = getCurrentUserId(source)
    if not account or not user_id then return end
    local rows = awaitQuery('SELECT user_id FROM am_vrp_characters WHERE account_identifier = @account LIMIT 1', {account = account})
    if #rows == 0 then
        awaitExec('INSERT IGNORE INTO am_vrp_characters (account_identifier,user_id,slot) VALUES (@account,@user_id,1)', {
            account = account, user_id = user_id
        })
    end
end

AddEventHandler('vRP:playerJoin', function(user_id, source)
    CreateThread(function()
        local account = accountIdentifier(source)
        if not account then return end
        local exists = awaitQuery('SELECT user_id FROM am_vrp_characters WHERE account_identifier = @account AND user_id = @user_id LIMIT 1', {
            account = account, user_id = user_id
        })
        if #exists == 0 then
            local slots = awaitQuery('SELECT COALESCE(MAX(slot),0)+1 AS slot FROM am_vrp_characters WHERE account_identifier = @account', {account = account})
            local slot = tonumber(slots[1] and slots[1].slot) or 1
            awaitExec('INSERT IGNORE INTO am_vrp_characters (account_identifier,user_id,slot) VALUES (@account,@user_id,@slot)', {
                account = account, user_id = user_id, slot = slot
            })
        end
    end)
end)

local function ownsCharacter(source, user_id)
    local account = accountIdentifier(source)
    if not account then return false end
    local rows = awaitQuery('SELECT 1 FROM am_vrp_characters WHERE account_identifier = @account AND user_id = @user_id LIMIT 1', {
        account = account, user_id = tonumber(user_id)
    })
    return #rows > 0
end

local function saveAndDetach(source, triggerLeave)
    local current = getCurrentUserId(source)
    if not current then return true end

    local data = vRP.getUserDataTable(current)
    if data then
        vRP.setUData(current, 'vRP:datatable', json.encode(data))
    end

    if triggerLeave ~= false then
        TriggerEvent('vRP:playerLeave', current, source)
    end

    local reverseKey = vRP.rusers[current]
    if reverseKey then vRP.users[reverseKey] = nil end
    vRP.rusers[current] = nil
    vRP.user_tables[current] = nil
    vRP.user_tmp_tables[current] = nil
    vRP.user_sources[current] = nil
    return true
end

local function attach(source, user_id)
    user_id = tonumber(user_id)
    if not user_id or not ownsCharacter(source, user_id) then return false, 'character_not_owned' end
    if vRP.rusers[user_id] and vRP.rusers[user_id] ~= accountIdentifier(source) then return false, 'character_already_online' end

    local current = getCurrentUserId(source)
    if current == user_id then return true end
    if current then saveAndDetach(source, true) end

    local ids = GetPlayerIdentifiers(source)
    if not ids or not ids[1] then return false, 'identifier_missing' end

    local userRows = awaitQuery('SELECT * FROM vrp_users WHERE id = @id LIMIT 1', {id = user_id})
    local userdata = userRows[1]
    if not userdata then return false, 'character_missing' end
    if tonumber(userdata.banned) == 1 then return false, 'character_banned' end

    vRP.users[ids[1]] = user_id
    vRP.rusers[user_id] = ids[1]
    vRP.user_tables[user_id] = {}
    vRP.user_tmp_tables[user_id] = {}
    vRP.user_sources[user_id] = source

    local dataRows = awaitQuery("SELECT dvalue FROM vrp_user_data WHERE user_id = @id AND dkey = 'vRP:datatable' LIMIT 1", {id = user_id})
    local decoded = dataRows[1] and json.decode(dataRows[1].dvalue or '') or nil
    if type(decoded) == 'table' then vRP.user_tables[user_id] = decoded end

    local tmp = vRP.user_tmp_tables[user_id]
    tmp.last_login = userdata.last_login or ''
    tmp.spawns = 0
    tmp.pings = 0

    awaitExec('UPDATE vrp_users SET last_login = @login WHERE id = @id', {
        id = user_id,
        login = (GetPlayerEndpoint(source) or 'unknown') .. ' ' .. os.date('%H:%M:%S %d/%m/%Y')
    })

    TriggerEvent('vRP:playerJoin', user_id, source, GetPlayerName(source), tmp.last_login)
    TriggerEvent('am_lib:vrp:characterSelected', source, user_id)
    return true
end

function vRP.amGetCharacters(source)
    ensurePrimaryCharacter(source)
    local account = accountIdentifier(source)
    if not account then return {} end
    return awaitQuery([[
        SELECT c.user_id AS id, c.user_id, c.slot,
               i.firstname, i.name AS lastname, i.age, i.phone, i.registration,
               m.wallet AS cash, m.bank,
               u.last_login, u.whitelisted, u.banned
        FROM am_vrp_characters c
        LEFT JOIN vrp_user_identities i ON i.user_id = c.user_id
        LEFT JOIN vrp_user_moneys m ON m.user_id = c.user_id
        LEFT JOIN vrp_users u ON u.id = c.user_id
        WHERE c.account_identifier = @account
        ORDER BY c.slot ASC
    ]], {account = account})
end

function vRP.amSelectCharacter(source, characterId)
    return attach(source, characterId)
end

function vRP.amCreateCharacter(source, data)
    data = type(data) == 'table' and data or {}
    local account = accountIdentifier(source)
    if not account then return false, 'identifier_missing' end

    local slotRows = awaitQuery('SELECT COALESCE(MAX(slot),0)+1 AS slot FROM am_vrp_characters WHERE account_identifier = @account', {account = account})
    local slot = tonumber(data.slot) or tonumber(slotRows[1] and slotRows[1].slot) or 1
    local conflict = awaitQuery('SELECT 1 FROM am_vrp_characters WHERE account_identifier = @account AND slot = @slot LIMIT 1', {account = account, slot = slot})
    if #conflict > 0 then return false, 'slot_in_use' end

    local current = getCurrentUserId(source)
    local whitelist = 0
    if current then
        local rows = awaitQuery('SELECT whitelisted FROM vrp_users WHERE id = @id LIMIT 1', {id = current})
        whitelist = tonumber(rows[1] and rows[1].whitelisted) or 0
    end

    local user_id = awaitInsert('INSERT INTO vrp_users (whitelisted,banned) VALUES (@whitelisted,0)', {whitelisted = whitelist})
    user_id = tonumber(user_id)
    if not user_id then return false, 'create_user_failed' end

    awaitExec('INSERT INTO am_vrp_characters (account_identifier,user_id,slot) VALUES (@account,@user_id,@slot)', {
        account = account, user_id = user_id, slot = slot
    })

    if data.firstname or data.firstName or data.lastname or data.lastName or data.name then
        awaitExec([[
            INSERT INTO vrp_user_identities (user_id,registration,phone,firstname,name,age)
            VALUES (@user_id,@registration,@phone,@firstname,@lastname,@age)
        ]], {
            user_id = user_id,
            registration = data.registration,
            phone = data.phone,
            firstname = data.firstname or data.firstName or '',
            lastname = data.lastname or data.lastName or data.name or '',
            age = tonumber(data.age) or 18
        })
    end

    awaitExec('INSERT IGNORE INTO vrp_user_moneys (user_id,wallet,bank,debt,depositOnLogin) VALUES (@user_id,0,0,0,0)', {user_id = user_id})
    return {id = user_id, user_id = user_id, slot = slot}
end

function vRP.amDeleteCharacter(source, characterId)
    local user_id = tonumber(characterId)
    if not user_id or not ownsCharacter(source, user_id) then return false, 'character_not_owned' end
    if getCurrentUserId(source) == user_id then return false, 'cannot_delete_active_character' end
    awaitExec('DELETE FROM am_vrp_characters WHERE account_identifier = @account AND user_id = @user_id', {
        account = accountIdentifier(source), user_id = user_id
    })
    awaitExec('DELETE FROM vrp_users WHERE id = @user_id', {user_id = user_id})
    return true
end

function vRP.amLogoutCharacter(source)
    local current = getCurrentUserId(source)
    if not current then return true end
    saveAndDetach(source, true)
    TriggerEvent('am_lib:vrp:characterLoggedOut', source, current)
    return true
end

function vRP.amGetCharacterSpawnData(source, characterId)
    local user_id = tonumber(characterId)
    if not user_id or not ownsCharacter(source, user_id) then return nil end
    local rows = awaitQuery("SELECT dvalue FROM vrp_user_data WHERE user_id = @id AND dkey = 'vRP:datatable' LIMIT 1", {id = user_id})
    local data = rows[1] and json.decode(rows[1].dvalue or '') or nil
    if type(data) ~= 'table' then return nil end
    return data.position or data.pos or data.coords
end

print('^5[AM vRP Patch]^7 Character compatibility loaded.')
