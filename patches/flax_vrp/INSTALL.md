# AM Lib - FlaxHosting vRP patch

Denne mappe er **kun en compatibility patch til vRP core**. Den indeholder ingen multicharacter UI/resource.

## Hvorfor patchen er nødvendig
FlaxHosting-basen binder en spiller direkte til ét `user_id` under `playerConnecting` via `vrp_user_ids`. AM Lib beholder den normale første vRP-karakter som bootstrap, men patchen gør det muligt at skifte til og oprette flere normale vRP `user_id`-karakterer på samme account.

## Installation
1. Importér `install.sql` i databasen.
2. Kopiér `modules/am_multicharacter.lua` til:
   `resources/[vrp]/vrp/modules/am_multicharacter.lua`
3. Åbn `resources/[vrp]/vrp/__resource.lua`.
4. Lige efter `"base.lua",` tilføj:
   `"modules/am_multicharacter.lua",`
5. Sørg for rækkefølgen:
   `ensure oxmysql` -> `ensure vrp` -> `ensure am_lib` -> dit multicharacter-script.

## API dit multicharacter-script bruger
Dit multicharacter-script skal KUN kalde AM Lib:

```lua
local AM = exports.am_lib:GetLib()

local characters = AM.Character.GetCharacters(source)
AM.Character.Select(source, characterId)
AM.Character.Create(source, data)
AM.Character.Delete(source, characterId)
AM.Character.Logout(source)
```

Eller exports direkte:

```lua
exports.am_lib:GetCharacters(source)
exports.am_lib:SelectCharacter(source, characterId)
exports.am_lib:CreateCharacter(source, data)
exports.am_lib:DeleteCharacter(source, characterId)
exports.am_lib:LogoutCharacter(source)
```

## Bemærkning
Patchen er lavet mod den offentlige FlaxHosting-Filer vRP-base (legacy vRP/Proxy/Tunnel + oxmysql). Andre stærkt modificerede vRP forks kan kræve en lille adapter, men multicharacter-scriptet skal stadig ikke ændres.
