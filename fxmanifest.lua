fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'AM Development'
description 'Unified bridge/core library for AM Development resources'
version '1.0.0'

shared_scripts {
    'config.lua',
    'shared/init.lua',
    'shared/utils.lua',
    'shared/locales.lua',
    'core/bootstrap.lua',
    'core/bridge.lua',
    'core/modules.lua',
    'core/cache.lua',
    'core/character.lua',
    'bridges/framework/*.lua',
    'bridges/inventory/*.lua',
    'bridges/target/*.lua',
    'bridges/dispatch/*.lua',
    'bridges/fuel/*.lua',
    'bridges/keys/*.lua',
    'bridges/multicharacter/*.lua',
    'modules/init.lua',
    'modules/validation.lua',
    'modules/diagnostics.lua',
    'custom/init.lua',
    'custom/bridge_template.lua'
}

client_scripts {
    'client/core.lua',
    'client/framework.lua',
    'client/target.lua',
    'client/ui.lua',
    'client/npc.lua',
    'client/vehicle.lua',
    'client/dispatch.lua',
    'client/callbacks.lua',
    'client/blips.lua',
    'client/objects.lua',
    'client/zones.lua',
    'client/animations.lua',
    'client/vehicle_integrations.lua',
    'client/integrations.lua',
    'client/character.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/updater.lua',
    'bridges/database/*.lua',
    'server/core.lua',
    'server/framework.lua',
    'server/inventory.lua',
    'server/permissions.lua',
    'server/callbacks.lua',
    'server/logging.lua',
    'server/dispatch.lua',
    'server/database.lua',
    'server/billing.lua',
    'server/society.lua',
    'server/usable.lua',
    'server/metadata.lua',
    'server/integrations.lua',
    'server/garage.lua',
    'server/character.lua'
}

files {
    'locales/*.json',
    'update.json'
}

provide 'am_lib'
