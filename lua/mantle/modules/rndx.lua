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

local SHADERS_VERSION = "1751924186"
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
	512, 512,
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
	["$basetexture"] = "_rt_PowerOfTwoFB",
	["$texture1"] = "_rt_FullFrameFB",
})

local SHAPES = {
	[SHAPE_CIRCLE] = 2,
	[SHAPE_FIGMA] = 2.2,
	[SHAPE_IOS] = 4,
}

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
local SHAPE, OUTLINE_THICKNESS, AA, BLUR_INTENSITY
local function RESET_PARAMS()
	MAT = nil
	X, Y, W, H = 0, 0, 0, 0
	TL, TR, BL, BR = 0, 0, 0, 0
	TEXTURE = nil
	USING_BLUR, BLUR_INTENSITY = false, 1.0
	COL_R, COL_G, COL_B, COL_A = 255, 255, 255, 255
	SHAPE, OUTLINE_THICKNESS, AA = SHAPES[SHAPE_FIGMA], -1, 0
end

local function SetupDraw()
	local max_rad = math_min(W, H) / 2
	TL, TR, BL, BR = math_clamp(TL, 0, max_rad), math_clamp(TR, 0, max_rad), math_clamp(BL, 0, max_rad),
		math_clamp(BR, 0, max_rad)

	local matrix = MATRIXES[MAT]
	MATRIX_SetUnpacked(
		matrix,

		BL, W, OUTLINE_THICKNESS or -1, 0,
		BR, H, AA, 0,
		TR, SHAPE, BLUR_INTENSITY or 1.0, 0,
		TL, TEXTURE and 1 or 0, 0, 0
	)
	MATERIAL_SetMatrix(MAT, "$viewprojmat", matrix)

	if COL_R then
		surface_SetDrawColor(COL_R, COL_G, COL_B, COL_A)
	end

	surface_SetMaterial(MAT)
end

local MANUAL_COLOR = NEW_FLAG()
local DEFAULT_DRAW_FLAGS = SHAPE_FIGMA

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
	SHAPE = SHAPES[bit_band(flags, SHAPE_CIRCLE + SHAPE_FIGMA + SHAPE_IOS)] or SHAPES[SHAPE_FIGMA]
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
	SHAPE = SHAPES[bit_band(flags, SHAPE_CIRCLE + SHAPE_FIGMA + SHAPE_IOS)] or SHAPES[SHAPE_FIGMA]
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
	SHAPE = SHAPES[bit_band(flags, SHAPE_CIRCLE + SHAPE_FIGMA + SHAPE_IOS)] or SHAPES[SHAPE_FIGMA]
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

return RNDX
