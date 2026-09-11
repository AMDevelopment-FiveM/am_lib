AM.UI = AM.UI or {}

function AM.UI.Notify(data)
    data = type(data) == 'string' and {description=data} or (data or {})
    if AM.Utils.ResourceStarted('ox_lib') and lib and lib.notify then
        lib.notify({title=data.title or 'AM', description=data.description or '', type=data.type or 'inform', duration=data.duration or 5000})
        return true
    end
    if AM.Bridges.framework == 'esx' and AM.Utils.ResourceStarted('es_extended') then
        exports['es_extended']:getSharedObject().ShowNotification(data.description or data.title or '')
        return true
    end
    if AM.Bridges.framework == 'qb' and AM.Utils.ResourceStarted('qb-core') then
        exports['qb-core']:GetCoreObject().Functions.Notify(data.description or data.title or '', data.type or 'primary', data.duration or 5000)
        return true
    end
    SetNotificationTextEntry('STRING'); AddTextComponentString(data.description or data.title or ''); DrawNotification(false, false)
    return true
end

function AM.UI.Progress(data)
    data = data or {}
    if AM.Utils.ResourceStarted('ox_lib') and lib and lib.progressBar then
        return lib.progressBar({duration=data.duration or 1000, label=data.label or 'Arbejder...', canCancel=data.canCancel ~= false, disable=data.disable})
    end
    Wait(data.duration or 1000)
    return true
end

function AM.UI.TextUI(text)
    if AM.Utils.ResourceStarted('ox_lib') and lib and lib.showTextUI then lib.showTextUI(text); return end
    BeginTextCommandDisplayHelp('STRING'); AddTextComponentSubstringPlayerName(text); EndTextCommandDisplayHelp(0, false, true, -1)
end

function AM.UI.HideTextUI()
    if AM.Utils.ResourceStarted('ox_lib') and lib and lib.hideTextUI then lib.hideTextUI() end
end

AM.Notify = AM.UI.Notify
AM.Progress = AM.UI.Progress
exports('Notify', AM.UI.Notify)
exports('Progress', AM.UI.Progress)
