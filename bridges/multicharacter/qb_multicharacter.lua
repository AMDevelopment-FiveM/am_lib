-- Compatibility marker for qb-multicharacter.
-- Character operations fall back to the QBCore framework bridge unless an
-- explicit runtime provider is registered by the multicharacter resource.
AM.Character.RegisterProvider('qb_multicharacter', {
    GetCharacters = function() return nil end,
    Select = function() return nil end,
    Create = function() return nil end,
    Delete = function() return nil end,
    Logout = function() return nil end
})
