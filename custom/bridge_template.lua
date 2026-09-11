-- Custom bridge template. Copy this file, rename the adapter, and keep AM scripts unchanged.
-- Nothing is registered by default, so this file is safe to leave enabled.
AM.Custom.Template = AM.Custom.Template or {
    register = function(category, name, adapter)
        return AM.Custom.RegisterBridge(category, name, adapter)
    end
}
