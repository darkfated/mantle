CreateClientConVar('mantle_depth_ui', 1, true, false)

Mantle.ui = {
    convar = {
        depth_ui = GetConVar('mantle_depth_ui'):GetBool()
    }
}

cvars.AddChangeCallback('mantle_depth_ui', function(_, _, newValue)
    Mantle.ui.convar.depth_ui = newValue == '1'
end)
