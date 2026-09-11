AM.Validate = AM.Validate or {}

function AM.Validate.Source(src)
    src = tonumber(src)
    return src and src > 0 and GetPlayerName(src) ~= nil
end

function AM.Validate.Amount(amount, max)
    amount = tonumber(amount)
    if not amount or amount <= 0 then return false end
    if max and amount > max then return false end
    return true
end

function AM.Validate.Distance(source, coords, maxDistance)
    if not IsDuplicityVersion() then return false end
    local ped = GetPlayerPed(source)
    if ped == 0 then return false end
    local p = GetEntityCoords(ped)
    return #(p - coords) <= (maxDistance or 5.0)
end
