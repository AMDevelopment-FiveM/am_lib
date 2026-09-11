AM.Utils = AM.Utils or {}

function AM.Utils.Debug(...)
    if not AMConfig.Debug then return end
    print(('^5[AM_LIB DEBUG]^7 %s'):format(table.concat({...}, ' ')))
end

function AM.Utils.ResourceStarted(name)
    return GetResourceState(name) == 'started'
end

function AM.Utils.FirstStarted(resources)
    for i = 1, #resources do
        if AM.Utils.ResourceStarted(resources[i]) then
            return resources[i]
        end
    end
end

function AM.Utils.DeepCopy(tbl)
    if type(tbl) ~= 'table' then return tbl end
    local out = {}
    for k, v in pairs(tbl) do out[AM.Utils.DeepCopy(k)] = AM.Utils.DeepCopy(v) end
    return out
end

function AM.Utils.Clamp(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end
