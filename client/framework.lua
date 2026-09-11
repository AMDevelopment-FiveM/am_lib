AM.Player = AM.Player or {}

function AM.Player.GetData()
    local bridge = AM.Bridges.framework or AMConfig.Framework
    if bridge == 'esx' and AM.Utils.ResourceStarted('es_extended') then
        local ESX = exports['es_extended']:getSharedObject()
        return ESX.GetPlayerData()
    elseif (bridge == 'qb' or bridge == 'qbox') and AM.Utils.ResourceStarted(bridge == 'qbox' and 'qbx_core' or 'qb-core') then
        if bridge == 'qbox' then
            return exports.qbx_core:GetPlayerData()
        end
        return exports['qb-core']:GetCoreObject().Functions.GetPlayerData()
    end
    return { source = GetPlayerServerId(PlayerId()) }
end

function AM.Player.GetJob()
    local data = AM.Player.GetData()
    return data and (data.job or data.Job) or nil
end

function AM.Player.HasJob(job, minGrade)
    local current = AM.Player.GetJob()
    if not current then return false end
    local name = current.name or current.id
    local grade = current.grade
    if type(grade) == 'table' then grade = grade.level or grade.grade or 0 end
    return name == job and (not minGrade or (tonumber(grade) or 0) >= minGrade)
end

exports('GetPlayerData', AM.Player.GetData)
exports('GetJob', AM.Player.GetJob)
exports('HasJob', AM.Player.HasJob)
