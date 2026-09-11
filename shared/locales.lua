AM.Locale = AM.Locale or {}
AM.Locale.current = AMConfig.Locale or 'da'
AM.Locale.data = AM.Locale.data or {}

local fallback = {
    da = { no_access='Du har ikke adgang til dette.', not_enough_money='Du har ikke nok penge.', inventory_full='Der er ikke plads i dit inventory.', invalid_request='Ugyldig anmodning.', action_failed='Handlingen mislykkedes.' },
    en = { no_access='You do not have access to this.', not_enough_money='You do not have enough money.', inventory_full='There is not enough inventory space.', invalid_request='Invalid request.', action_failed='The action failed.' }
}

local function loadLocale(name)
    local raw = LoadResourceFile(GetCurrentResourceName(), ('locales/%s.json'):format(name))
    if raw and raw ~= '' then
        local ok, decoded = pcall(json.decode, raw)
        if ok and type(decoded) == 'table' then return decoded end
    end
    return fallback[name] or fallback.en
end

AM.Locale.data.da = loadLocale('da')
AM.Locale.data.en = loadLocale('en')
if not AM.Locale.data[AM.Locale.current] then AM.Locale.data[AM.Locale.current] = loadLocale(AM.Locale.current) end

function AM.Locale.Set(name)
    AM.Locale.current = name
    AM.Locale.data[name] = AM.Locale.data[name] or loadLocale(name)
end

function AM.Locale.T(key, ...)
    local lang = AM.Locale.data[AM.Locale.current] or AM.Locale.data.en
    local text = lang[key] or (AM.Locale.data.en and AM.Locale.data.en[key]) or key
    if select('#', ...) > 0 then return string.format(text, ...) end
    return text
end

AM.T = AM.Locale.T
exports('Translate', AM.Locale.T)
