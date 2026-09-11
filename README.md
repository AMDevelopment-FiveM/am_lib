# am_lib

Shared FiveM library for AM Development resources.

`am_lib` provides a single API for common framework-dependent features such as players, inventories, targets, dispatch, vehicles, NPCs, callbacks, character handling and other integrations.

## Requirements

- FiveM server artifact with Lua 5.4 support
- `oxmysql`

Other integrations are optional and can be auto-detected.

## Installation

1. Place `am_lib` in your resources folder.
2. Configure the integrations you want in `config.lua`.
3. Start `am_lib` before resources that depend on it.

```cfg
ensure oxmysql
ensure am_lib
```

## Supported frameworks

- vRP
- ESX
- QBCore
- QBox
- Standalone fallback

## Integrations

The library includes bridges for common inventory, target, dispatch, fuel, vehicle key, garage, billing, phone, doorlock and database resources.

Most integrations can be left on `auto` in `config.lua`.

```lua
AMConfig.Framework = 'auto'
AMConfig.Inventory = 'auto'
AMConfig.Target = 'auto'
AMConfig.Dispatch = 'auto'
```

## Usage

```lua
local AM = exports.am_lib:GetLib()
```

### Player and inventory

```lua
if AM.Player.HasJob(source, 'police') then
    AM.Inventory.Add(source, 'radio', 1)
end
```

### NPC

```lua
local npc = AM.NPC.Create({
    model = 's_m_y_cop_01',
    coords = vec4(441.15, -981.94, 30.69, 90.0),
    target = {
        {
            name = 'police_garage',
            label = 'Open garage',
            icon = 'fa-solid fa-car',
            onSelect = function()
                TriggerEvent('am_police:garage')
            end
        }
    }
})
```

### Character API

`am_lib` does not provide a multicharacter UI. It exposes a framework-independent character API that multicharacter resources can use.

```lua
local characters = AM.Character.GetCharacters(source)
AM.Character.Select(source, characterId)
AM.Character.Create(source, data)
AM.Character.Delete(source, characterId)
AM.Character.Logout(source)
```

Custom character systems can register a provider through the public provider API.

## vRP multicharacter

A compatibility patch for legacy/Flax-style vRP is included in:

```text
patches/flax_vrp/
```

Read `patches/flax_vrp/INSTALL.md` before installing it. The patch is optional and is only required when the vRP base itself does not support multiple characters per account.

## Auto updater

The updater can check a GitHub repository on resource start and install files listed in `update.json`.

Configure it in `config.lua`:

```lua
AMConfig.Updater = {
    enabled = true,
    owner = 'AM-Development',
    repo = 'am_lib',
    branch = 'main',
    basePath = '',
    manifest = 'update.json',
    autoRestart = true,
    checkOnStart = true,
    checkDelayMs = 2500,
    console = true
}
```

Run a manual check from the server console with:

```text
amlibupdate
```

`config.lua`, `custom/` and `backups/` are excluded from automatic replacement.

To generate a new update manifest after changing files:

```bash
python tools/generate_update_manifest.py
```

## Project structure

```text
am_lib/
├── bridges/
├── client/
├── core/
├── custom/
├── locales/
├── modules/
├── patches/
├── server/
├── shared/
├── tools/
├── config.lua
├── fxmanifest.lua
└── update.json
```

## Versioning

This project follows semantic versioning.

Current release: `1.0.0`

## License

Copyright AM Development. Add your chosen license before publishing the repository publicly.
