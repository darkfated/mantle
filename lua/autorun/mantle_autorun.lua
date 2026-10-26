if SERVER then
    AddCSLuaFile('mantle/init.lua')
    AddCSLuaFile('mantle/modules/rndx.lua')
end

if CLIENT then
    RNDX = include('mantle/modules/rndx.lua')
end

include('mantle/init.lua')