AM.Animation = AM.Animation or {}
local function loadDict(dict) RequestAnimDict(dict); local t=GetGameTimer()+8000 while not HasAnimDictLoaded(dict) and GetGameTimer()<t do Wait(0) end return HasAnimDictLoaded(dict) end
function AM.Animation.Play(data)
    local ped=data.ped or PlayerPedId()
    if data.scenario then TaskStartScenarioInPlace(ped,data.scenario,0,data.enterAnim~=false); return true end
    if not data.dict or not data.clip or not loadDict(data.dict) then return false end
    TaskPlayAnim(ped,data.dict,data.clip,data.blendIn or 8.0,data.blendOut or -8.0,data.duration or -1,data.flag or 49,data.rate or 0.0,false,false,false); return true
end
function AM.Animation.Stop(ped) ClearPedTasks(ped or PlayerPedId()) end
