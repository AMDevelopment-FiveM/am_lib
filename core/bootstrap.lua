AM = AM or {}
AM.Core = AM.Core or {}

function AM.Core.SafeCall(fn, ...)
    if type(fn) ~= 'function' then return false, 'invalid_function' end
    local ok, a, b, c, d = pcall(fn, ...)
    if not ok then
        if AM.Utils and AM.Utils.Debug then AM.Utils.Debug('SafeCall error:', a) end
        return false, a
    end
    return true, a, b, c, d
end

function AM.Core.RequireVersion(required)
    local function parts(v)
        local a,b,c = tostring(v or '0.0.0'):match('^(%d+)%.(%d+)%.(%d+)')
        return tonumber(a) or 0, tonumber(b) or 0, tonumber(c) or 0
    end
    local a,b,c = parts(AM.Version)
    local x,y,z = parts(required)
    if a ~= x then return a > x end
    if b ~= y then return b > y end
    return c >= z
end

function AM.Core.AssertVersion(required, resource)
    if AM.Core.RequireVersion(required) then return true end
    error(('[AM_LIB] %s requires am_lib >= %s (installed: %s)'):format(resource or GetInvokingResource() or 'resource', required, AM.Version or 'unknown'))
end
