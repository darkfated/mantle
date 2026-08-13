RNDX = include('mantle/modules/rndx.lua')
if CLIENT then
    RNDX.SetDefaultShape(RNDX.SHAPE_IOS)
end

AddCSLuaFile('mantle/init.lua')
include('mantle/init.lua')
