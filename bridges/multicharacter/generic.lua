-- Generic compatibility provider.
-- Other multicharacter resources can register themselves at runtime with:
-- exports.am_lib:RegisterCharacterProvider('my_multicharacter', { ... })
-- Then set AMConfig.Multicharacter = 'my_multicharacter'.
--
-- Required/optional provider methods:
-- GetCharacters(source) -> table
-- Select(source, characterId, data) -> boolean
-- Create(source, data) -> character/boolean
-- Delete(source, characterId) -> boolean
-- Logout(source) -> boolean
-- GetSpawnData(source, characterId) -> table|nil

AM.Character.RegisterProvider('generic', {
    GetCharacters = function() return nil end,
    Select = function() return nil end,
    Create = function() return nil end,
    Delete = function() return nil end,
    Logout = function() return nil end,
    GetSpawnData = function() return nil end
})
