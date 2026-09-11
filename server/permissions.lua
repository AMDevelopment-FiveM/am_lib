AM.Permission = AM.Permission or {}
AM.Permission.Custom = AM.Permission.Custom or {}
function AM.Permission.Register(name,cb) AM.Permission.Custom[name]=cb end
function AM.Permission.Has(source,permission)
    local cb=AM.Permission.Custom[permission]; if cb then return cb(source)==true end
    if IsPlayerAceAllowed(source,permission) then return true end
    if permission:sub(1,4)=='job:' then
        local job,grade=permission:match('job:([^:]+):?(%d*)')
        return AM.Player.HasJob(source,job,grade~='' and tonumber(grade) or nil)
    end
    return false
end
exports('HasPermission',AM.Permission.Has)
exports('RegisterPermission',AM.Permission.Register)
