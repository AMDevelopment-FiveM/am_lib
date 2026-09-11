AM.Cache = AM.Cache or { data = {} }

local function now()
    return GetGameTimer and GetGameTimer() or math.floor(os.clock() * 1000)
end

function AM.Cache.Set(key, value, ttl)
    AM.Cache.data[key] = { value = value, expires = ttl and (now() + ttl) or nil }
    return value
end

function AM.Cache.Get(key)
    local row = AM.Cache.data[key]
    if not row then return nil end
    if row.expires and now() >= row.expires then
        AM.Cache.data[key] = nil
        return nil
    end
    return row.value
end

function AM.Cache.Remove(key) AM.Cache.data[key] = nil end
function AM.Cache.Clear() AM.Cache.data = {} end
