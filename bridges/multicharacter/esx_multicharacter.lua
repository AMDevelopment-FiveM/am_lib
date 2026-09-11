-- Compatibility marker for esx_multicharacter.
-- ESX character handling differs by ESX version, therefore the framework bridge
-- or a runtime provider is used instead of hard-coding private events here.
AM.Character.RegisterProvider('esx_multicharacter', {
    GetCharacters = function() return nil end,
    Select = function() return nil end,
    Create = function() return nil end,
    Delete = function() return nil end,
    Logout = function() return nil end
})
