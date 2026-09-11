AM.Target = AM.Target or {}

local function normalize(options)
    local out = {}
    for i, opt in ipairs(options or {}) do
        out[i] = {
            name = opt.name or ('am_target_' .. i),
            icon = opt.icon,
            label = opt.label or 'Interact',
            distance = opt.distance or 2.0,
            canInteract = opt.canInteract,
            groups = opt.groups,
            items = opt.items,
            bones = opt.bones,
            offset = opt.offset,
            offsetAbsolute = opt.offsetAbsolute,
            onSelect = opt.onSelect or function(data)
                if opt.event then
                    TriggerEvent(opt.event, data)
                elseif opt.serverEvent then
                    TriggerServerEvent(opt.serverEvent, data)
                end
            end
        }
    end
    return out
end

function AM.Target.AddEntity(entity, options)
    if not entity or entity == 0 or not DoesEntityExist(entity) then return false end

    local bridge = AM.Bridges and AM.Bridges.target or 'standalone'

    if bridge == 'ox_target' and GetResourceState('ox_target') == 'started' then
        exports.ox_target:addLocalEntity(entity, normalize(options))
        return true
    elseif bridge == 'qb_target' and GetResourceState('qb-target') == 'started' then
        local qbOpts = {}
        local distance = 2.0
        for _, o in ipairs(options or {}) do
            distance = math.max(distance, tonumber(o.distance) or 2.0)
            qbOpts[#qbOpts + 1] = {
                icon = o.icon,
                label = o.label,
                action = o.onSelect,
                event = o.event,
                canInteract = o.canInteract
            }
        end
        exports['qb-target']:AddTargetEntity(entity, {
            options = qbOpts,
            distance = distance
        })
        return true
    end

    if AM.Utils and AM.Utils.Debug then
        AM.Utils.Debug(('No target bridge available for entity %s (bridge=%s)'):format(entity, tostring(bridge)))
    end
    return false
end

function AM.Target.RemoveEntity(entity, optionNames)
    if not entity or entity == 0 then return false end

    if AM.Bridges and AM.Bridges.target == 'ox_target' and GetResourceState('ox_target') == 'started' then
        exports.ox_target:removeLocalEntity(entity, optionNames)
        return true
    elseif AM.Bridges and AM.Bridges.target == 'qb_target' and GetResourceState('qb-target') == 'started' then
        exports['qb-target']:RemoveTargetEntity(entity)
        return true
    end

    return false
end

function AM.Target.AddBoxZone(data)
    if AM.Bridges and AM.Bridges.target == 'ox_target' and GetResourceState('ox_target') == 'started' then
        return exports.ox_target:addBoxZone({
            coords = data.coords,
            size = data.size or vec3(2.0, 2.0, 2.0),
            rotation = data.rotation or 0.0,
            debug = data.debug or false,
            options = normalize(data.options)
        })
    elseif AM.Bridges and AM.Bridges.target == 'qb_target' and GetResourceState('qb-target') == 'started' then
        return exports['qb-target']:AddBoxZone(
            data.name,
            data.coords,
            (data.size and data.size.x) or 2.0,
            (data.size and data.size.y) or 2.0,
            {
                name = data.name,
                heading = data.rotation or 0.0,
                debugPoly = data.debug or false
            },
            {
                options = data.options or {},
                distance = data.distance or 2.0
            }
        )
    end
end

exports('AddEntityTarget', AM.Target.AddEntity)
exports('RemoveEntityTarget', AM.Target.RemoveEntity)
exports('AddBoxZone', AM.Target.AddBoxZone)
