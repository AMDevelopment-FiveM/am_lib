AM.Object = AM.Object or {}
AM.Object.Items = AM.Object.Items or {}
local function loadModel(model)
    model=type(model)=='string' and joaat(model) or model
    if not IsModelInCdimage(model) then return nil end
    RequestModel(model); local untilAt=GetGameTimer()+10000
    while not HasModelLoaded(model) and GetGameTimer()<untilAt do Wait(0) end
    return HasModelLoaded(model) and model or nil
end
function AM.Object.Create(data)
    local m=loadModel(data.model); if not m then return nil,'invalid_model' end
    local c=data.coords; local obj=CreateObject(m,c.x,c.y,c.z,data.networked==true,true,false)
    if data.heading then SetEntityHeading(obj,data.heading+0.0) end
    if data.rotation then SetEntityRotation(obj,data.rotation.x+0.0,data.rotation.y+0.0,data.rotation.z+0.0,2,true) end
    FreezeEntityPosition(obj,data.freeze==true); SetEntityInvincible(obj,data.invincible==true)
    if data.placeOnGround then PlaceObjectOnGroundProperly(obj) end
    if data.attachTo then AttachEntityToEntity(obj,data.attachTo,data.bone or 0,(data.offset or vec3(0,0,0)).x,(data.offset or vec3(0,0,0)).y,(data.offset or vec3(0,0,0)).z,(data.attachRotation or vec3(0,0,0)).x,(data.attachRotation or vec3(0,0,0)).y,(data.attachRotation or vec3(0,0,0)).z,false,false,false,false,2,true) end
    SetModelAsNoLongerNeeded(m); local id=data.id or ('object:%s'):format(obj); AM.Object.Items[id]=obj; return id,obj
end
function AM.Object.Delete(id)
    local obj=AM.Object.Items[id] or id; if obj and DoesEntityExist(obj) then DeleteEntity(obj) end; AM.Object.Items[id]=nil
end
AddEventHandler('onResourceStop',function(res) if res~=GetCurrentResourceName() then return end for id in pairs(AM.Object.Items) do AM.Object.Delete(id) end end)
