function ulx.mantle_menu( calling_ply )
    if not IsValid(calling_ply) then return ULib.tsayError(calling_ply, "Only from game!") end
    calling_ply:ConCommand("mantle_menu")
end
local mantle_menu = ulx.command("Menus", "ulx mantle_menu", ulx.mantle_menu, { "!mantle_menu", "!mmenu" }, true)
mantle_menu:defaultAccess(ULib.ACCESS_ALL)
mantle_menu:help("Открыть меню Mantle")