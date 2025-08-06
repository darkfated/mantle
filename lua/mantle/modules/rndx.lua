--[[
Copyright (c) 2025 Srlion (https://github.com/Srlion)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

if SERVER then
	AddCSLuaFile()
	return
end

local bit_band = bit.band
local surface_SetDrawColor = surface.SetDrawColor
local surface_SetMaterial = surface.SetMaterial
local surface_DrawTexturedRectUV = surface.DrawTexturedRectUV
local surface_DrawTexturedRect = surface.DrawTexturedRect
local render_CopyRenderTargetToTexture = render.CopyRenderTargetToTexture
local math_min = math.min
local math_max = math.max
local DisableClipping = DisableClipping
local type = type

local SHADERS_VERSION = "1754382102"
local SHADERS_GMA = [========[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]========]
do
	local DECODED_SHADERS_GMA = util.Base64Decode(SHADERS_GMA)
	if not DECODED_SHADERS_GMA or #DECODED_SHADERS_GMA == 0 then
		print("Failed to load shaders!") -- this shouldn't happen
		return
	end

	file.Write("rndx_shaders_" .. SHADERS_VERSION .. ".gma", DECODED_SHADERS_GMA)
	game.MountGMA("data/rndx_shaders_" .. SHADERS_VERSION .. ".gma")
end

local function GET_SHADER(name)
	return SHADERS_VERSION:gsub("%.", "_") .. "_" .. name
end

local BLUR_RT = GetRenderTargetEx("RNDX" .. SHADERS_VERSION .. SysTime(),
	1024, 1024,
	RT_SIZE_LITERAL,
	MATERIAL_RT_DEPTH_SEPARATE,
	bit.bor(2, 256, 4, 8 --[[4, 8 is clamp_s + clamp-t]]),
	0,
	IMAGE_FORMAT_BGRA8888
)

-- I know it exists in gmod, but I want to have math.min and math.max localized
local function math_clamp(val, min, max)
	return (math_min(math_max(val, min), max))
end

local NEW_FLAG; do
	local flags_n = -1
	function NEW_FLAG()
		flags_n = flags_n + 1
		return 2 ^ flags_n
	end
end

local NO_TL, NO_TR, NO_BL, NO_BR           = NEW_FLAG(), NEW_FLAG(), NEW_FLAG(), NEW_FLAG()

-- Svetov/Jaffies's great idea!
local SHAPE_CIRCLE, SHAPE_FIGMA, SHAPE_IOS = NEW_FLAG(), NEW_FLAG(), NEW_FLAG()

local BLUR                                 = NEW_FLAG()

local RNDX                                 = {}

local shader_mat                           = [==[
screenspace_general
{
	$pixshader ""
	$vertexshader ""

	$basetexture ""
	$texture1    ""
	$texture2    ""
	$texture3    ""

	// Mandatory, don't touch
	$ignorez            1
	$vertexcolor        1
	$vertextransform    1
	"<dx90"
	{
		$no_draw 1
	}

	$copyalpha                 0
	$alpha_blend_color_overlay 0
	$alpha_blend               1 // for AA
	$linearwrite               1 // to disable broken gamma correction for colors
	$linearread_basetexture    1 // to disable broken gamma correction for textures
	$linearread_texture1       1 // to disable broken gamma correction for textures
	$linearread_texture2       1 // to disable broken gamma correction for textures
	$linearread_texture3       1 // to disable broken gamma correction for textures
}
]==]

local MATRIXES                             = {}

local function create_shader_mat(name, opts)
	assert(name and isstring(name), "create_shader_mat: tex must be a string")

	local key_values = util.KeyValuesToTable(shader_mat, false, true)

	if opts then
		for k, v in pairs(opts) do
			key_values[k] = v
		end
	end

	local mat = CreateMaterial(
		"rndx_shaders1" .. name .. SysTime(),
		"screenspace_general",
		key_values
	)

	MATRIXES[mat] = Matrix()

	return mat
end

local ROUNDED_MAT = create_shader_mat("rounded", {
	["$pixshader"] = GET_SHADER("rndx_rounded_ps30"),
	["$vertexshader"] = GET_SHADER("rndx_vertex_vs30"),
})
local ROUNDED_TEXTURE_MAT = create_shader_mat("rounded_texture", {
	["$pixshader"] = GET_SHADER("rndx_rounded_ps30"),
	["$vertexshader"] = GET_SHADER("rndx_vertex_vs30"),
	["$basetexture"] = "loveyoumom", -- if there is no base texture, you can't change it later
})

local BLUR_VERTICAL = "$c0_x"
local ROUNDED_BLUR_MAT = create_shader_mat("blur_horizontal", {
	["$pixshader"] = GET_SHADER("rndx_rounded_blur_ps30"),
	["$vertexshader"] = GET_SHADER("rndx_vertex_vs30"),
	["$basetexture"] = BLUR_RT:GetName(),
	["$texture1"] = "_rt_FullFrameFB",
})

local SHADOWS_MAT = create_shader_mat("rounded_shadows", {
	["$pixshader"] = GET_SHADER("rndx_shadows_ps30"),
	["$vertexshader"] = GET_SHADER("rndx_vertex_vs30"),
})

local SHADOWS_BLUR_MAT = create_shader_mat("shadows_blur_horizontal", {
	["$pixshader"] = GET_SHADER("rndx_shadows_blur_ps30"),
	["$vertexshader"] = GET_SHADER("rndx_vertex_vs30"),
	["$basetexture"] = BLUR_RT:GetName(),
	["$texture1"] = "_rt_FullFrameFB",
})

local SHAPES = {
	[SHAPE_CIRCLE] = 2,
	[SHAPE_FIGMA] = 2.2,
	[SHAPE_IOS] = 4,
}
local DEFAULT_SHAPE = SHAPE_FIGMA

local MATERIAL_SetTexture = ROUNDED_MAT.SetTexture
local MATERIAL_SetMatrix = ROUNDED_MAT.SetMatrix
local MATERIAL_SetFloat = ROUNDED_MAT.SetFloat
local MATRIX_SetUnpacked = Matrix().SetUnpacked

local MAT
local X, Y, W, H
local TL, TR, BL, BR
local TEXTURE
local USING_BLUR, BLUR_INTENSITY
local COL_R, COL_G, COL_B, COL_A
local SHAPE, OUTLINE_THICKNESS, AA
local START_ANGLE, END_ANGLE, ROTATION
local function RESET_PARAMS()
	MAT = nil
	X, Y, W, H = 0, 0, 0, 0
	TL, TR, BL, BR = 0, 0, 0, 0
	TEXTURE = nil
	USING_BLUR, BLUR_INTENSITY = false, 1.0
	COL_R, COL_G, COL_B, COL_A = 255, 255, 255, 255
	SHAPE, OUTLINE_THICKNESS, AA = SHAPES[DEFAULT_SHAPE], -1, 0
	START_ANGLE, END_ANGLE, ROTATION = 0, 360, 0
end

local function SetupDraw()
	local max_rad = math_min(W, H) / 2
	TL, TR, BL, BR = math_clamp(TL, 0, max_rad), math_clamp(TR, 0, max_rad), math_clamp(BL, 0, max_rad),
		math_clamp(BR, 0, max_rad)

	local matrix = MATRIXES[MAT]
	MATRIX_SetUnpacked(
		matrix,

		BL, W, OUTLINE_THICKNESS or -1, END_ANGLE,
		BR, H, AA, ROTATION,
		TR, SHAPE, BLUR_INTENSITY or 1.0, 0,
		TL, TEXTURE and 1 or 0, START_ANGLE, 0
	)
	MATERIAL_SetMatrix(MAT, "$viewprojmat", matrix)

	if COL_R then
		surface_SetDrawColor(COL_R, COL_G, COL_B, COL_A)
	end

	surface_SetMaterial(MAT)
end

local MANUAL_COLOR = NEW_FLAG()
local DEFAULT_DRAW_FLAGS = DEFAULT_SHAPE

local function draw_rounded(x, y, w, h, col, flags, tl, tr, bl, br, texture, thickness)
	if col and col.a == 0 then
		return
	end

	RESET_PARAMS()

	if not flags then
		flags = DEFAULT_DRAW_FLAGS
	end

	local using_blur = bit_band(flags, BLUR) ~= 0
	if using_blur then
		return RNDX.DrawBlur(x, y, w, h, flags, tl, tr, bl, br, thickness)
	end

	MAT = ROUNDED_MAT; if texture then
		MAT = ROUNDED_TEXTURE_MAT
		MATERIAL_SetTexture(MAT, "$basetexture", texture)
		TEXTURE = texture
	end

	W, H = w, h
	TL, TR, BL, BR = bit_band(flags, NO_TL) == 0 and tl or 0,
		bit_band(flags, NO_TR) == 0 and tr or 0,
		bit_band(flags, NO_BL) == 0 and bl or 0,
		bit_band(flags, NO_BR) == 0 and br or 0
	SHAPE = SHAPES[bit_band(flags, SHAPE_CIRCLE + SHAPE_FIGMA + SHAPE_IOS)] or SHAPES[DEFAULT_SHAPE]
	OUTLINE_THICKNESS = thickness

	if bit_band(flags, MANUAL_COLOR) ~= 0 then
		COL_R = nil
	elseif col then
		COL_R, COL_G, COL_B, COL_A = col.r, col.g, col.b, col.a
	else
		COL_R, COL_G, COL_B, COL_A = 255, 255, 255, 255
	end

	SetupDraw()

	-- https://github.com/Jaffies/rboxes/blob/main/rboxes.lua
	-- fixes setting $basetexture to ""(none) not working correctly
	return surface_DrawTexturedRectUV(x, y, w, h, -0.015625, -0.015625, 1.015625, 1.015625)
end

function RNDX.Draw(r, x, y, w, h, col, flags)
	return draw_rounded(x, y, w, h, col, flags, r, r, r, r)
end

function RNDX.DrawOutlined(r, x, y, w, h, col, thickness, flags)
	return draw_rounded(x, y, w, h, col, flags, r, r, r, r, nil, thickness or 1)
end

function RNDX.DrawTexture(r, x, y, w, h, col, texture, flags)
	return draw_rounded(x, y, w, h, col, flags, r, r, r, r, texture)
end

function RNDX.DrawMaterial(r, x, y, w, h, col, mat, flags)
	local tex = mat:GetTexture("$basetexture")
	if tex then
		return RNDX.DrawTexture(r, x, y, w, h, col, tex, flags)
	end
end

function RNDX.DrawCircle(x, y, r, col, flags)
	return RNDX.Draw(r / 2, x - r / 2, y - r / 2, r, r, col, (flags or 0) + SHAPE_CIRCLE)
end

function RNDX.DrawCircleOutlined(x, y, r, col, thickness, flags)
	return RNDX.DrawOutlined(r / 2, x - r / 2, y - r / 2, r, r, col, thickness, (flags or 0) + SHAPE_CIRCLE)
end

function RNDX.DrawCircleTexture(x, y, r, col, texture, flags)
	return RNDX.DrawTexture(r / 2, x - r / 2, y - r / 2, r, r, col, texture, (flags or 0) + SHAPE_CIRCLE)
end

function RNDX.DrawCircleMaterial(x, y, r, col, mat, flags)
	return RNDX.DrawMaterial(r / 2, x - r / 2, y - r / 2, r, r, col, mat, (flags or 0) + SHAPE_CIRCLE)
end

local USE_SHADOWS_BLUR = false
local SHADOWS_AA = 0
function RNDX.DrawBlur(x, y, w, h, flags, tl, tr, bl, br, thickness)
	RESET_PARAMS()

	if not flags then
		flags = DEFAULT_DRAW_FLAGS
	end

	if USE_SHADOWS_BLUR then
		MAT = SHADOWS_BLUR_MAT
		AA = SHADOWS_AA
	else
		MAT = ROUNDED_BLUR_MAT
	end

	W, H = w, h
	TL, TR, BL, BR = bit_band(flags, NO_TL) == 0 and tl or 0,
		bit_band(flags, NO_TR) == 0 and tr or 0,
		bit_band(flags, NO_BL) == 0 and bl or 0,
		bit_band(flags, NO_BR) == 0 and br or 0
	SHAPE = SHAPES[bit_band(flags, SHAPE_CIRCLE + SHAPE_FIGMA + SHAPE_IOS)] or SHAPES[DEFAULT_SHAPE]
	OUTLINE_THICKNESS = thickness

	COL_R, COL_G, COL_B, COL_A = 255, 255, 255, 255

	SetupDraw()

	render_CopyRenderTargetToTexture(BLUR_RT)
	MATERIAL_SetFloat(MAT, BLUR_VERTICAL, 0)
	surface_DrawTexturedRect(x, y, w, h)

	render_CopyRenderTargetToTexture(BLUR_RT)
	MATERIAL_SetFloat(MAT, BLUR_VERTICAL, 1)
	return surface_DrawTexturedRect(x, y, w, h)
end

function RNDX.DrawShadowsEx(x, y, w, h, col, flags, tl, tr, bl, br, spread, intensity, thickness)
	if col and col.a == 0 then
		return
	end

	-- if we are inside a panel, we need to draw outside of it
	local old_clipping_state = DisableClipping(true)

	if not flags then
		flags = DEFAULT_DRAW_FLAGS
	end

	local using_blur = bit_band(flags, BLUR) ~= 0
	if using_blur then
		SHADOWS_AA = intensity
		USE_SHADOWS_BLUR = true
		RNDX.DrawBlur(x, y, w, h, flags, tl, tr, bl, br, thickness)
		USE_SHADOWS_BLUR = false
	end

	RESET_PARAMS()

	-- Shadows are a bit bigger than the actual box
	spread = spread or 30
	intensity = intensity or spread * 1.2

	x = x - spread
	y = y - spread
	w = w + (spread * 2)
	h = h + (spread * 2)

	tl = tl + (spread * 2)
	tr = tr + (spread * 2)
	bl = bl + (spread * 2)
	br = br + (spread * 2)
	--

	MAT = SHADOWS_MAT

	W, H = w, h
	TL, TR, BL, BR = bit_band(flags, NO_TL) == 0 and tl or 0,
		bit_band(flags, NO_TR) == 0 and tr or 0,
		bit_band(flags, NO_BL) == 0 and bl or 0,
		bit_band(flags, NO_BR) == 0 and br or 0
	SHAPE = SHAPES[bit_band(flags, SHAPE_CIRCLE + SHAPE_FIGMA + SHAPE_IOS)] or SHAPES[DEFAULT_SHAPE]
	OUTLINE_THICKNESS = thickness

	AA = intensity

	if bit_band(flags, MANUAL_COLOR) ~= 0 then
		COL_R = nil
	elseif col then
		COL_R, COL_G, COL_B, COL_A = col.r, col.g, col.b, col.a
	else
		COL_R, COL_G, COL_B, COL_A = 0, 0, 0, 255
	end

	SetupDraw()
	-- https://github.com/Jaffies/rboxes/blob/main/rboxes.lua
	-- fixes having no $basetexture causing uv to be broken
	surface_DrawTexturedRectUV(x, y, w, h, -0.015625, -0.015625, 1.015625, 1.015625)

	return DisableClipping(old_clipping_state)
end

function RNDX.DrawShadows(r, x, y, w, h, col, spread, intensity, flags)
	return RNDX.DrawShadowsEx(x, y, w, h, col, flags, r, r, r, r, spread, intensity)
end

function RNDX.DrawShadowsOutlined(r, x, y, w, h, col, thickness, spread, intensity, flags)
	return RNDX.DrawShadowsEx(x, y, w, h, col, flags, r, r, r, r, spread, intensity, thickness or 1)
end

local BASE_FUNCS = {
	Rad = function(self, rad)
		TL, TR, BL, BR = rad, rad, rad, rad
		return self
	end,
	Radii = function(self, tl, tr, bl, br)
		TL, TR, BL, BR = tl or 0, tr or 0, bl or 0, br or 0
		return self
	end,
	Texture = function(self, texture)
		TEXTURE = texture
		return self
	end,
	Material = function(self, mat)
		local tex = mat:GetTexture("$basetexture")
		if tex then
			TEXTURE = tex
		end
		return self
	end,
	Outline = function(self, thickness)
		OUTLINE_THICKNESS = thickness
		return self
	end,
	Shape = function(self, shape)
		SHAPE = SHAPES[shape] or 2.2
		return self
	end,
	Color = function(self, col_or_r, g, b, a)
		if type(col_or_r) == "number" then
			COL_R, COL_G, COL_B, COL_A = col_or_r, g or 255, b or 255, a or 255
		else
			COL_R, COL_G, COL_B, COL_A = col_or_r.r, col_or_r.g, col_or_r.b, col_or_r.a
		end
		return self
	end,
	Blur = function(self, intensity)
		if not intensity then
			intensity = 1.0
		end
		intensity = math_max(intensity, 0)
		USING_BLUR, BLUR_INTENSITY = true, intensity
		return self
	end,
	Rotation = function(self, angle)
		ROTATION = math.rad(angle or 0)
		return self
	end,
	StartAngle = function(self, angle)
		START_ANGLE = angle or 0
		return self
	end,
	EndAngle = function(self, angle)
		END_ANGLE = angle or 360
		return self
	end,
}

local RECT = {
	Rad = BASE_FUNCS.Rad,
	Radii = BASE_FUNCS.Radii,
	Texture = BASE_FUNCS.Texture,
	Material = BASE_FUNCS.Material,
	Outline = BASE_FUNCS.Outline,
	Shape = BASE_FUNCS.Shape,
	Color = BASE_FUNCS.Color,
	Blur = BASE_FUNCS.Blur,
	Rotation = BASE_FUNCS.Rotation,
	StartAngle = BASE_FUNCS.StartAngle,
	EndAngle = BASE_FUNCS.EndAngle,

	Draw = function()
		if USING_BLUR then
			MAT = ROUNDED_BLUR_MAT
			COL_R, COL_G, COL_B, COL_A = 255, 255, 255, 255
			SetupDraw()

			render_CopyRenderTargetToTexture(BLUR_RT)
			MATERIAL_SetFloat(MAT, BLUR_VERTICAL, 0)
			surface_DrawTexturedRect(X, Y, W, H)

			render_CopyRenderTargetToTexture(BLUR_RT)
			MATERIAL_SetFloat(MAT, BLUR_VERTICAL, 1)
			return surface_DrawTexturedRect(X, Y, W, H)
		end
		if TEXTURE then
			MAT = ROUNDED_TEXTURE_MAT
			MATERIAL_SetTexture(MAT, "$basetexture", TEXTURE)
		end
		SetupDraw()
		return surface_DrawTexturedRectUV(X, Y, W, H, -0.015625, -0.015625, 1.015625, 1.015625)
	end
}

local CIRCLE = {
	Texture = BASE_FUNCS.Texture,
	Material = BASE_FUNCS.Material,
	Outline = BASE_FUNCS.Outline,
	Color = BASE_FUNCS.Color,
	Blur = BASE_FUNCS.Blur,
	Rotation = BASE_FUNCS.Rotation,
	StartAngle = BASE_FUNCS.StartAngle,
	EndAngle = BASE_FUNCS.EndAngle,

	Draw = RECT.Draw
}

local TYPES = {
	Rect = function(x, y, w, h)
		RESET_PARAMS()
		MAT = ROUNDED_MAT
		X, Y, W, H = x, y, w, h
		return RECT
	end,
	Circle = function(x, y, r)
		RESET_PARAMS()
		MAT = ROUNDED_MAT
		SHAPE = SHAPES[SHAPE_CIRCLE]
		X, Y, W, H = x - r / 2, y - r / 2, r, r
		r = r / 2
		TL, TR, BL, BR = r, r, r, r
		return CIRCLE
	end
}

setmetatable(RNDX, {
	__call = function()
		return TYPES
	end
})

-- Flags
RNDX.NO_TL = NO_TL
RNDX.NO_TR = NO_TR
RNDX.NO_BL = NO_BL
RNDX.NO_BR = NO_BR

RNDX.SHAPE_CIRCLE = SHAPE_CIRCLE
RNDX.SHAPE_FIGMA = SHAPE_FIGMA
RNDX.SHAPE_IOS = SHAPE_IOS

RNDX.BLUR = BLUR
RNDX.MANUAL_COLOR = MANUAL_COLOR

function RNDX.SetFlag(flags, flag, bool)
	flag = RNDX[flag] or flag
	if tobool(bool) then
		return bit.bor(flags, flag)
	else
		return bit.band(flags, bit.bnot(flag))
	end
end

function RNDX.SetDefaultShape(shape)
	DEFAULT_SHAPE = shape or SHAPE_FIGMA
	DEFAULT_DRAW_FLAGS = DEFAULT_SHAPE
end

return RNDX
