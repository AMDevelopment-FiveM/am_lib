local RESOURCE = GetCurrentResourceName()
local CURRENT_VERSION = GetResourceMetadata(RESOURCE, 'version', 0) or '0.0.0'

local function log(message)
    local cfg = AMConfig and AMConfig.Updater or nil
    if cfg and cfg.console == false then return end
    print(('^5[AM_LIB]^7 %s'):format(message))
end

local function trimSlash(value)
    value = tostring(value or '')
    value = value:gsub('^/+', ''):gsub('/+$', '')
    return value
end

local function encodePath(path)
    -- Keep slashes but escape spaces and the few characters commonly used in file names.
    return tostring(path):gsub(' ', '%%20'):gsub('#', '%%23')
end

local function safePath(path)
    if type(path) ~= 'string' or path == '' then return false end
    if path:find('\\', 1, true) or path:sub(1, 1) == '/' then return false end
    if path:find('..', 1, true) then return false end
    return true
end

local function splitVersion(v)
    local out = {}
    for part in tostring(v or '0'):gmatch('[0-9]+') do
        out[#out + 1] = tonumber(part) or 0
    end
    return out
end

local function isNewer(remote, current)
    local a, b = splitVersion(remote), splitVersion(current)
    local n = math.max(#a, #b)
    for i = 1, n do
        local av, bv = a[i] or 0, b[i] or 0
        if av > bv then return true end
        if av < bv then return false end
    end
    return false
end

local function rawBase(cfg)
    local basePath = trimSlash(cfg.basePath)
    local base = ('https://raw.githubusercontent.com/%s/%s/%s'):format(cfg.owner, cfg.repo, cfg.branch or 'main')
    if basePath ~= '' then base = base .. '/' .. basePath end
    return base
end

local function request(url, cb)
    PerformHttpRequest(url, function(status, body, headers, err)
        cb(status or 0, body or '', headers or {}, err)
    end, 'GET', '', {
        ['User-Agent'] = ('AM-Lib-Updater/%s'):format(CURRENT_VERSION),
        ['Cache-Control'] = 'no-cache'
    })
end

local function protectedPath(path)
    if path == 'config.lua' then return true end
    if path:sub(1, 7) == 'custom/' then return true end
    if path:sub(1, 8) == 'backups/' then return true end
    return false
end

local updating = false

local function installManifest(manifest, cfg, base)
    local files = manifest.files
    if type(files) ~= 'table' then
        log('^1Update manifest is invalid: files[] is missing.^7')
        updating = false
        return
    end

    local queue = {}
    for _, entry in ipairs(files) do
        local path = type(entry) == 'table' and entry.path or entry
        if safePath(path) and not protectedPath(path) then
            queue[#queue + 1] = path
        end
    end

    if #queue == 0 then
        log('^1Update manifest contains no installable files.^7')
        updating = false
        return
    end

    log(('Downloading ^2%d^7 files for v%s...'):format(#queue, tostring(manifest.version)))

    -- Stage every download in memory first. Nothing is written until ALL downloads succeed.
    local staged, index = {}, 1
    local function downloadNext()
        local path = queue[index]
        if not path then
            local written = 0
            for _, item in ipairs(staged) do
                local ok = SaveResourceFile(RESOURCE, item.path, item.body, #item.body)
                if not ok then
                    log(('^1Failed writing %s. Update stopped.^7'):format(item.path))
                    updating = false
                    return
                end
                written = written + 1
            end

            -- Optional deletions are only executed after all new files were written.
            if type(manifest.delete) == 'table' then
                local resourcePath = GetResourcePath(RESOURCE)
                for _, pathToDelete in ipairs(manifest.delete) do
                    if safePath(pathToDelete) and not protectedPath(pathToDelete) then
                        local full = resourcePath .. '/' .. pathToDelete
                        pcall(os.remove, full)
                    end
                end
            end

            log(('^2Update v%s installed successfully (%d files).^7'):format(tostring(manifest.version), written))
            updating = false

            if cfg.autoRestart ~= false then
                log('Restarting am_lib to load the new version...')
                SetTimeout(1500, function()
                    ExecuteCommand(('restart %s'):format(RESOURCE))
                end)
            else
                log('^3Restart am_lib/server to load the new version.^7')
            end
            return
        end

        local url = base .. '/' .. encodePath(path)
        request(url, function(status, body)
            if status ~= 200 or body == '' then
                log(('^1Download failed (%s, HTTP %s). No files were changed.^7'):format(path, status))
                updating = false
                return
            end
            staged[#staged + 1] = { path = path, body = body }
            index = index + 1
            downloadNext()
        end)
    end

    downloadNext()
end

function AMCheckForUpdates(force)
    if updating then
        if force then log('An update check is already running.') end
        return
    end

    local cfg = AMConfig and AMConfig.Updater or nil
    if not cfg or cfg.enabled == false then
        if force then log('Updater is disabled in config.lua.') end
        return
    end

    if not cfg.owner or cfg.owner == '' or not cfg.repo or cfg.repo == '' then
        log(('Running v%s. GitHub updater is ready, but Owner/Repo is not configured yet.'):format(CURRENT_VERSION))
        return
    end

    updating = true
    local base = rawBase(cfg)
    local manifestPath = trimSlash(cfg.manifest or 'update.json')
    local manifestUrl = base .. '/' .. encodePath(manifestPath)

    log(('Current version: ^3%s^7. Checking GitHub...'):format(CURRENT_VERSION))
    request(manifestUrl, function(status, body)
        if status ~= 200 then
            log(('^1Could not check GitHub (HTTP %s).^7'):format(status))
            updating = false
            return
        end

        local ok, manifest = pcall(json.decode, body)
        if not ok or type(manifest) ~= 'table' or not manifest.version then
            log('^1GitHub update.json could not be parsed.^7')
            updating = false
            return
        end

        if not isNewer(manifest.version, CURRENT_VERSION) then
            log(('^2am_lib is up to date (v%s).^7'):format(CURRENT_VERSION))
            updating = false
            return
        end

        log(('^3Update found: v%s -> v%s.^7'):format(CURRENT_VERSION, tostring(manifest.version)))
        installManifest(manifest, cfg, base)
    end)
end

exports('CheckForUpdates', function()
    AMCheckForUpdates(true)
end)

RegisterCommand('amlibupdate', function(source)
    if source ~= 0 then return end -- console only
    AMCheckForUpdates(true)
end, true)

CreateThread(function()
    local cfg = AMConfig and AMConfig.Updater or nil
    if not cfg or cfg.enabled == false then return end
    if cfg.checkOnStart == false then return end
    Wait(tonumber(cfg.checkDelayMs) or 2500)
    AMCheckForUpdates(false)
end)
