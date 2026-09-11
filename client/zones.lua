AM.Zone = AM.Zone or {}
AM.Zone.Items = AM.Zone.Items or {}
local seq=0
function AM.Zone.Create(data)
    seq=seq+1; local id=data.id or ('zone:%d'):format(seq)
    local inside=false
    CreateThread(function()
        while AM.Zone.Items[id] do
            local wait=500; local p=GetEntityCoords(PlayerPedId()); local hit=false
            if data.type=='box' or not data.type then
                local s=data.size or vec3(2,2,2); hit=math.abs(p.x-data.coords.x)<=s.x/2 and math.abs(p.y-data.coords.y)<=s.y/2 and math.abs(p.z-data.coords.z)<=s.z/2
            elseif data.type=='sphere' then hit=#(p-data.coords)<= (data.radius or 2.0) end
            if hit then wait=100 end
            if hit and not inside then inside=true; if data.onEnter then data.onEnter(id) end end
            if not hit and inside then inside=false; if data.onExit then data.onExit(id) end end
            while hit and AM.Zone.Items[id] and data.inside do data.inside(id); Wait(data.insideInterval or 0); p=GetEntityCoords(PlayerPedId()); hit=(data.type=='sphere' and #(p-data.coords)<= (data.radius or 2.0)) or hit; if data.type~='sphere' then local s=data.size or vec3(2,2,2); hit=math.abs(p.x-data.coords.x)<=s.x/2 and math.abs(p.y-data.coords.y)<=s.y/2 and math.abs(p.z-data.coords.z)<=s.z/2 end end
            Wait(wait)
        end
    end)
    AM.Zone.Items[id]=data; return id
end
function AM.Zone.Remove(id) AM.Zone.Items[id]=nil end
