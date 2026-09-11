AMConfig = {}

AMConfig.Debug = false
AMConfig.Locale = 'da'
AMConfig.AutoDetect = true

AMConfig.Framework = 'auto' -- auto, vrp, esx, qb, qbox, standalone
AMConfig.Inventory = 'auto' -- auto, ox_inventory, qb_inventory, vrp, esx, standalone
AMConfig.Target = 'auto' -- auto, ox_target, qb_target, standalone
AMConfig.Dispatch = 'auto' -- auto, ps_dispatch, cd_dispatch, qs_dispatch, rcore_dispatch, standalone
AMConfig.Database = 'oxmysql'
AMConfig.Fuel = 'auto'
AMConfig.Keys = 'auto' -- auto, qb_vehiclekeys, renewed_vehiclekeys, standalone
AMConfig.Billing = 'auto' -- auto, esx_billing, qb_management, standalone
AMConfig.Garage = 'auto' -- auto, qb_garages, jg_advancedgarages, standalone
AMConfig.Phone = 'auto' -- auto, lb_phone, qs_smartphone, standalone
AMConfig.Doorlock = 'auto' -- auto, ox_doorlock, qb_doorlock, standalone
AMConfig.Boss = 'auto' -- auto, qb_management, esx_society, standalone
AMConfig.Skillcheck = 'auto' -- auto, ox_lib, standalone
AMConfig.Minigame = 'auto' -- auto, ps_ui, standalone
AMConfig.Multicharacter = 'auto' -- vRP uses vrp_core automatically; QB/ESX/QBox use their normal providers

AMConfig.VRPMulticharacter = {
        resource = '',
    resources = {},

    exports = {
        GetCharacters = nil,
        Select = nil,
        Create = nil,
        Delete = nil,
        Logout = nil,
        GetSpawnData = nil
    }
}


-- GitHub updater. Leave owner/repo empty to disable until the repository is configured.
AMConfig.Updater = {
    enabled = true,
    owner = '',
    repo = '',
    branch = 'main',
    basePath = '',
    manifest = 'update.json',
    autoRestart = true,
    checkOnStart = true,
    checkDelayMs = 2500,
    console = true
}

AMConfig.Modules = {
    npc = true,
    target = true,
    inventory = true,
    dispatch = true,
    vehicles = true,
    ui = true,
    permissions = true,
    callbacks = true,
    logging = true,
    security = true,
    database = true,
    billing = true,
    society = true,
    usable = true,
    metadata = true,
    objects = true,
    zones = true,
    blips = true,
    animations = true,
    fuel = true,
    keys = true,
    garage = true,
    banking = true,
    boss = true,
    phone = true,
    doorlock = true,
    crafting = true,
    shops = true,
    weapons = true,
    entities = true,
    network = true,
    skillcheck = true,
    minigame = true,
    adapters = true,
    multicharacter = true
}

AMConfig.NPC = {
    defaultSpawnDistance = 80.0,
    defaultDespawnDistance = 100.0,
    respawnCheckMs = 3000
}

AMConfig.Security = {
    callbackTimeout = 10000,
    rateLimitWindowMs = 3000,
    maxCallsPerWindow = 15,
    strictServerValidation = true
}

AMConfig.Logging = {
    enabled = true,
    printToConsole = true,
    webhook = ''
}
