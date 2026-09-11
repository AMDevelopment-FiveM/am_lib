AM.Blip = AM.Blip or {}
AM.Blip.Items = AM.Blip.Items or {}

function AM.Blip.Create(data)
    assert(type(data)=='table' and data.coords, '[am_lib] Blip.Create requires coords')
    local b = AddBlipForCoord(data.coords.x+0.0, data.coords.y+0.0, data.coords.z+0.0)
    SetBlipSprite(b, data.sprite or 1)
    SetBlipScale(b, data.scale or 0.8)
    SetBlipDisplay(b, data.display or 4)
    SetBlipAsShortRange(b, data.shortRange ~= false)
    if data.colour or data.color then SetBlipColour(b, data.colour or data.color) end
    BeginTextCommandSetBlipName('STRING'); AddTextComponentString(data.label or 'AM'); EndTextCommandSetBlipName(b)
    local id=data.id or ('blip:%s'):format(b); AM.Blip.Items[id]=b; return id,b
end
function AM.Blip.Remove(id)
    local b=AM.Blip.Items[id] or id
    if b and DoesBlipExist(b) then RemoveBlip(b) end
    AM.Blip.Items[id]=nil
end
