RegisterNetEvent('am_lib:server:dispatchFallback',function(data)
    if not AM.Server.Allow(source,'dispatch') then return end
    for _,id in ipairs(GetPlayers()) do
        local src=tonumber(id)
        local allowed=not data.jobs
        if data.jobs then for _,job in ipairs(data.jobs) do if AM.Player.HasJob(src,job) then allowed=true break end end end
        if allowed then TriggerClientEvent('am_lib:client:fallbackDispatch',src,data) end
    end
end)
