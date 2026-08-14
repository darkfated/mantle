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
local math_ceil = math.ceil
local DisableClipping = DisableClipping
local type = type
local tobool = tobool

local RNDX = {}

---------------------------------------------------------------------------
-- SHADERS
---------------------------------------------------------------------------

local SHADERS_VERSION = "1786703297"
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

---------------------------------------------------------------------------
-- FLAGS & CONSTANTS
---------------------------------------------------------------------------

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
local MANUAL_COLOR                         = NEW_FLAG()

local SHAPES                               = {
	[SHAPE_CIRCLE] = 2,
	[SHAPE_FIGMA] = 2.2,
	[SHAPE_IOS] = 4,
}

local DEFAULT_SHAPE                        = SHAPE_FIGMA
local DEFAULT_BLUR_INTENSITY               = 1.0

local BLUR_VERTICAL                        = "$c0_x"
local SHADOW_OX_C, SHADOW_OY_C             = "$c0_y", "$c0_z"

local FLAG_FADE_TOP                        = 8
local FLAG_FADE_BOTTOM                     = 16

---------------------------------------------------------------------------
-- MATERIALS
---------------------------------------------------------------------------

local BASE_VMT                             = [==[
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
}
]==]

-- correct gamma mode only: disables gmod's broken gamma correction
local LINEAR_KVS                           = {
	["$linearwrite"] = 1,
	["$linearread_basetexture"] = 1,
	["$linearread_texture1"] = 1,
	["$linearread_texture2"] = 1,
	["$linearread_texture3"] = 1,
}

local MATRIXES                             = {}

local function create_shader_mat(name, opts)
	assert(name and isstring(name), "create_shader_mat: tex must be a string")
	local key_values = util.KeyValuesToTable(BASE_VMT, false, true)
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

-- legacy gamma: emulate gmod's normal (broken) gamma so colors match
-- draw.RoundedBox & other addons; gamma is applied in the vertex shader instead
local LEGACY_GAMMA = false

local ROUNDED_MAT, ROUNDED_TEXTURE_MAT, ROUNDED_BLUR_MAT, SHADOWS_MAT, SHADOWS_BLUR_MAT

local function create_materials()
	local vs = GET_SHADER(LEGACY_GAMMA and "rndx_vertex_gamma_vs30" or "rndx_vertex_vs30")
	local suffix = LEGACY_GAMMA and "_gamma" or ""

	local function make(name, opts)
		if not LEGACY_GAMMA then
			for k, v in pairs(LINEAR_KVS) do
				opts[k] = v
			end
		end
		opts["$vertexshader"] = vs
		return create_shader_mat(name .. suffix, opts)
	end

	ROUNDED_MAT = make("rounded", {
		["$pixshader"] = GET_SHADER("rndx_rounded_ps30"),
	})
	ROUNDED_TEXTURE_MAT = make("rounded_texture", {
		["$pixshader"] = GET_SHADER("rndx_rounded_ps30"),
		["$basetexture"] = "loveyoumom", -- if there is no base texture, you can't change it later
	})
	ROUNDED_BLUR_MAT = make("blur", {
		["$pixshader"] = GET_SHADER("rndx_rounded_blur_ps30"),
		["$basetexture"] = BLUR_RT:GetName(),
		["$texture1"] = "_rt_FullFrameFB",
	})
	SHADOWS_MAT = make("rounded_shadows", {
		["$pixshader"] = GET_SHADER("rndx_shadows_ps30"),
	})
	SHADOWS_BLUR_MAT = make("shadows_blur", {
		["$pixshader"] = GET_SHADER("rndx_shadows_blur_ps30"),
		["$basetexture"] = BLUR_RT:GetName(),
		["$texture1"] = "_rt_FullFrameFB",
	})
end

create_materials()

local MATERIAL_SetTexture = ROUNDED_MAT.SetTexture
local MATERIAL_SetMatrix = ROUNDED_MAT.SetMatrix
local MATERIAL_SetFloat = ROUNDED_MAT.SetFloat
local MATRIX_SetUnpacked = Matrix().SetUnpacked

---------------------------------------------------------------------------
-- DRAW STATE
---------------------------------------------------------------------------

local MAT
local X, Y, W, H
local TL, TR, BL, BR
local TEXTURE
local USING_BLUR, BLUR_INTENSITY, BLUR_ALPHA
local FADE_FLAG
local COL_SET, COL_R, COL_G, COL_B, COL_A
local SHAPE, OUTLINE_THICKNESS
local START_ANGLE, END_ANGLE, ROTATION
local CLIP_PANEL
local SHADOW_ENABLED, SHADOW_BLUR, SHADOW_SPREAD, SHADOW_OX, SHADOW_OY
local SHADOW_SIGMA, PAD
local RADII_NORMALIZED

local function RESET_PARAMS()
	MAT = nil
	X, Y, W, H = 0, 0, 0, 0
	TL, TR, BL, BR = 0, 0, 0, 0
	TEXTURE = nil
	USING_BLUR, BLUR_INTENSITY, BLUR_ALPHA = false, DEFAULT_BLUR_INTENSITY, 1
	FADE_FLAG = 0
	COL_SET, COL_R, COL_G, COL_B, COL_A = false, 255, 255, 255, 255
	SHAPE, OUTLINE_THICKNESS = SHAPES[DEFAULT_SHAPE], -1
	START_ANGLE, END_ANGLE, ROTATION = 0, 360, 0
	CLIP_PANEL = nil
	SHADOW_ENABLED = false
	SHADOW_BLUR, SHADOW_SPREAD, SHADOW_OX, SHADOW_OY = 0, 0, 0, 0
	SHADOW_SIGMA, PAD = 0, 0
	RADII_NORMALIZED = false
end

---------------------------------------------------------------------------
-- INTERNAL DRAWING
---------------------------------------------------------------------------

local normalize_corner_radii; do
	local HUGE = math.huge

	local function nzr(x)
		if x ~= x or x < 0 then return 0 end
		local lim = math_min(W, H)
		if x == HUGE then return lim end
		return x
	end

	function normalize_corner_radii()
		local TL, TR, BL, BR = nzr(TL), nzr(TR), nzr(BL), nzr(BR)

		local k = math_max(
			1,
			(TL + TR) / W,
			(BL + BR) / W,
			(TL + BL) / H,
			(TR + BR) / H
		)

		if k > 1 then
			local inv = 1 / k
			TL, TR, BL, BR = TL * inv, TR * inv, BL * inv, BR * inv
		end

		return math_max(TL, 0), math_max(TR, 0), math_max(BL, 0), math_max(BR, 0)
	end
end

local function SetupDraw()
	local TL, TR, BL, BR = TL, TR, BL, BR
	if not RADII_NORMALIZED then
		TL, TR, BL, BR = normalize_corner_radii()
	end

	local flags_f = 0
	if TEXTURE then flags_f = flags_f + 1 end -- FLAG_USE_TEXTURE
	if FADE_FLAG ~= 0 then flags_f = flags_f + FADE_FLAG end

	local start_rad, sweep_rad
	local sweep = END_ANGLE - START_ANGLE
	if sweep >= 360 then
		start_rad, sweep_rad = 0, -1 -- full circle, shaders skip arc math
	else
		if sweep < 0 then sweep = sweep + 360 end
		start_rad = (START_ANGLE % 360) * 0.017453292519943295
		sweep_rad = sweep * 0.017453292519943295
	end

	local slot_3z = SHADOW_ENABLED and SHADOW_SPREAD or 0

	local matrix = MATRIXES[MAT]
	MATRIX_SetUnpacked(
		matrix,

		BL, W, OUTLINE_THICKNESS or -1, sweep_rad,
		BR, H, SHADOW_SIGMA, ROTATION,
		TR, SHAPE, BLUR_INTENSITY or 1.0, slot_3z,
		TL, flags_f, start_rad, PAD
	)
	MATERIAL_SetMatrix(MAT, "$viewprojmat", matrix)

	if SHADOW_ENABLED then
		MATERIAL_SetFloat(MAT, SHADOW_OX_C, SHADOW_OX)
		MATERIAL_SetFloat(MAT, SHADOW_OY_C, SHADOW_OY)
	end

	if COL_R then
		surface_SetDrawColor(COL_R, COL_G, COL_B, COL_A)
	end

	surface_SetMaterial(MAT)
end

local function draw_blur(shadow)
	MAT = shadow and SHADOWS_BLUR_MAT or ROUNDED_BLUR_MAT

	COL_R, COL_G, COL_B, COL_A = 255, 255, 255, math.floor(255 * BLUR_ALPHA)
	SetupDraw()

	render_CopyRenderTargetToTexture(BLUR_RT)
	MATERIAL_SetFloat(MAT, BLUR_VERTICAL, 0)
	surface_DrawTexturedRect(X, Y, W, H)

	render_CopyRenderTargetToTexture(BLUR_RT)
	MATERIAL_SetFloat(MAT, BLUR_VERTICAL, 1)
	surface_DrawTexturedRect(X, Y, W, H)
end

local function setup_shadows()
	TL, TR, BL, BR = normalize_corner_radii()
	RADII_NORMALIZED = true

	-- css: negative spread shrinks the box to zero at most, never inverts it
	if SHADOW_SPREAD < 0 then
		local min_half = math_min(W, H) * 0.5
		if -SHADOW_SPREAD > min_half then SHADOW_SPREAD = -min_half end
	end

	-- css-style spread: grow the quad; radii growth happens IN THE SHADER now
	if SHADOW_SPREAD ~= 0 then
		X = X - SHADOW_SPREAD
		Y = Y - SHADOW_SPREAD
		W = W + SHADOW_SPREAD * 2
		H = H + SHADOW_SPREAD * 2
	end

	-- css-style offset
	X = X + SHADOW_OX
	Y = Y + SHADOW_OY
end

local function setup_pad()
	local pad = 0

	if SHADOW_ENABLED then
		local sigma = SHADOW_BLUR * 0.5
		if sigma < 0.0001 then sigma = 0.0001 end
		SHADOW_SIGMA = sigma
		pad = math_ceil(sigma * 3)
	end

	if ROTATION ~= 0 then
		local c = math.abs(math.cos(ROTATION))
		local si = math.abs(math.sin(ROTATION))
		local hw, hh = W * 0.5, H * 0.5
		local extra = math_max(hw * c + hh * si - hw, hw * si + hh * c - hh)
		if extra > 0 then pad = pad + math_ceil(extra) + 2 end
	end

	if pad > 0 then
		X = X - pad
		Y = Y - pad
		W = W + pad * 2
		H = H + pad * 2
	end
	PAD = pad
end

---------------------------------------------------------------------------
-- BUILDER
---------------------------------------------------------------------------

local BASE_FUNCS; BASE_FUNCS = {
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
		OUTLINE_THICKNESS = thickness or 1
		return self
	end,
	Shape = function(self, shape)
		SHAPE = SHAPES[shape] or SHAPES[DEFAULT_SHAPE]
		return self
	end,
	Color = function(self, col_or_r, g, b, a)
		COL_SET = true
		if type(col_or_r) == "number" then
			COL_R, COL_G, COL_B, COL_A = col_or_r, g or 255, b or 255, a or 255
		else
			COL_R, COL_G, COL_B, COL_A = col_or_r.r, col_or_r.g, col_or_r.b, col_or_r.a
		end
		return self
	end,
	ManualColor = function(self)
		COL_SET, COL_R = true, nil
		return self
	end,
	Blur = function(self, intensity)
		if not intensity then
			intensity = DEFAULT_BLUR_INTENSITY
		end
		USING_BLUR, BLUR_INTENSITY = true, math_max(intensity, 0)
		return self
	end,
	Alpha = function(self, alpha)
		BLUR_ALPHA = math_max(0, math_min(1, alpha or 1))
		return self
	end,
	Rotation = function(self, angle)
		ROTATION = math.rad(angle or 0)
		return self
	end,
	Angles = function(self, start_angle, end_angle)
		START_ANGLE = start_angle or 0
		END_ANGLE = end_angle or 360
		return self
	end,
	---@deprecated Use Angles(start_angle, end_angle) instead.
	StartAngle = function(self, angle)
		START_ANGLE = angle or 0
		return self
	end,
	---@deprecated Use Angles(start_angle, end_angle) instead.
	EndAngle = function(self, angle)
		END_ANGLE = angle or 360
		return self
	end,
	Shadow = function(self, blur, spread, offset_x, offset_y)
		SHADOW_ENABLED = true
		SHADOW_BLUR = math_max(blur or 20, 0)
		SHADOW_SPREAD = spread or 0
		SHADOW_OX = offset_x or 0
		SHADOW_OY = offset_y or 0
		return self
	end,
	Fade = function(self, top, bottom)
		top = math_max(0, math_min(1, top or 1))
		bottom = math_max(0, math_min(1, bottom or 0))
		if top == bottom then
			FADE_FLAG = 0
		elseif top > bottom then
			FADE_FLAG = FLAG_FADE_TOP
		else
			FADE_FLAG = FLAG_FADE_BOTTOM
		end
		return self
	end,
	Clip = function(self, pnl)
		CLIP_PANEL = pnl
		return self
	end,
	Flags = function(self, flags)
		flags = flags or 0

		-- Corner flags
		if bit_band(flags, NO_TL) ~= 0 then TL = 0 end
		if bit_band(flags, NO_TR) ~= 0 then TR = 0 end
		if bit_band(flags, NO_BL) ~= 0 then BL = 0 end
		if bit_band(flags, NO_BR) ~= 0 then BR = 0 end

		-- Shape flags
		local shape_flag = bit_band(flags, SHAPE_CIRCLE + SHAPE_FIGMA + SHAPE_IOS)
		if shape_flag ~= 0 then
			SHAPE = SHAPES[shape_flag] or SHAPES[DEFAULT_SHAPE]
		end

		-- Blur flag
		if bit_band(flags, BLUR) ~= 0 then
			BASE_FUNCS.Blur(self)
		end

		-- Manual color flag
		if bit_band(flags, MANUAL_COLOR) ~= 0 then
			COL_R = nil
		end

		return self
	end,

	Draw = function(self)
		if END_ANGLE == START_ANGLE then
			return -- nothing to draw
		end

		local OLD_CLIPPING_STATE
		if SHADOW_ENABLED or CLIP_PANEL then
			-- if we are inside a panel, we need to draw outside of it
			OLD_CLIPPING_STATE = DisableClipping(true)
		end

		if CLIP_PANEL then
			local sx, sy = CLIP_PANEL:LocalToScreen(0, 0)
			local sw, sh = CLIP_PANEL:GetSize()
			render.SetScissorRect(sx, sy, sx + sw, sy + sh, true)
		end

		if SHADOW_ENABLED then
			if not COL_SET then
				COL_R, COL_G, COL_B, COL_A = 0, 0, 0, 255 -- shadows default to black
			end
			setup_shadows()
			setup_pad()

			if USING_BLUR then
				local r, g, b, a = COL_R, COL_G, COL_B, COL_A
				draw_blur(true)
				COL_R, COL_G, COL_B, COL_A = r, g, b, a
			end

			MAT = SHADOWS_MAT
			SetupDraw()
			surface_DrawTexturedRectUV(X, Y, W, H, -0.015625, -0.015625, 1.015625, 1.015625)
		elseif USING_BLUR then
			setup_pad()
			draw_blur()
		else
			setup_pad()
			if TEXTURE then
				MAT = ROUNDED_TEXTURE_MAT
				MATERIAL_SetTexture(MAT, "$basetexture", TEXTURE)
			end

			SetupDraw()
			-- https://github.com/Jaffies/rboxes/blob/main/rboxes.lua
			-- fixes setting $basetexture to ""(none) not working correctly
			surface_DrawTexturedRectUV(X, Y, W, H, -0.015625, -0.015625, 1.015625, 1.015625)
		end

		if CLIP_PANEL then
			render.SetScissorRect(0, 0, 0, 0, false)
		end

		if SHADOW_ENABLED or CLIP_PANEL then
			DisableClipping(OLD_CLIPPING_STATE)
		end
	end,

	GetMaterial = function(self)
		if SHADOW_ENABLED or USING_BLUR then
			error("You can't get the material of a shadowed or blurred rectangle!")
		end

		setup_pad()

		if TEXTURE then
			MAT = ROUNDED_TEXTURE_MAT
			MATERIAL_SetTexture(MAT, "$basetexture", TEXTURE)
		end
		SetupDraw()

		return MAT, X, Y, W, H
	end,
}

local RECT, CIRCLE = {}, {}
for k, v in pairs(BASE_FUNCS) do
	RECT[k] = v
	-- circles don't have corner radii
	if k ~= "Rad" and k ~= "Radii" then
		CIRCLE[k] = v
	end
end

---------------------------------------------------------------------------
-- PUBLIC API
---------------------------------------------------------------------------

function RNDX.Rect(x, y, w, h)
	RESET_PARAMS()
	MAT = ROUNDED_MAT
	X, Y, W, H = x, y, w, h
	return RECT
end

function RNDX.Circle(x, y, radius)
	RESET_PARAMS()
	MAT = ROUNDED_MAT
	SHAPE = SHAPES[SHAPE_CIRCLE]
	local d = radius * 2
	X, Y, W, H = x - radius, y - radius, d, d
	TL, TR, BL, BR = radius, radius, radius, radius
	return CIRCLE
end

-- match gmod's default (broken) gamma so colors look the same as
-- draw.RoundedBox & other addons
function RNDX.SetLegacyGamma(enabled)
	enabled = tobool(enabled)
	if enabled == LEGACY_GAMMA then return end
	LEGACY_GAMMA = enabled
	create_materials()
end

function RNDX.SetDefaultShape(shape)
	DEFAULT_SHAPE = shape or SHAPE_FIGMA
end

function RNDX.SetDefaultBlurIntensity(val)
	DEFAULT_BLUR_INTENSITY = math_max(0, tonumber(val) or 1.0)
end

function RNDX.GetDefaultBlurIntensity()
	return DEFAULT_BLUR_INTENSITY
end

-- Flags for :Flags()
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

---------------------------------------------------------------------------
-- LEGACY API (deprecated, kept for backwards compatibility)
---------------------------------------------------------------------------

---@deprecated Use RNDX.Rect(x, y, w, h):Rad(r):Color(col):Draw() instead.
function RNDX.Draw(r, x, y, w, h, col, flags)
	if col and col.a == 0 then return end
	local rect = RNDX.Rect(x, y, w, h):Rad(r)
	if col then rect:Color(col) end
	if flags then rect:Flags(flags) end
	rect:Draw()
end

---@deprecated Use RNDX.Rect(...):Rad(r):Outline(thickness):Draw() instead.
function RNDX.DrawOutlined(r, x, y, w, h, col, thickness, flags)
	if col and col.a == 0 then return end
	local rect = RNDX.Rect(x, y, w, h):Rad(r):Outline(thickness or 1)
	if col then rect:Color(col) end
	if flags then rect:Flags(flags) end
	rect:Draw()
end

---@deprecated Use RNDX.Rect(...):Rad(r):Texture(texture):Draw() instead.
function RNDX.DrawTexture(r, x, y, w, h, col, texture, flags)
	if col and col.a == 0 then return end
	local rect = RNDX.Rect(x, y, w, h):Rad(r):Texture(texture)
	if col then rect:Color(col) end
	if flags then rect:Flags(flags) end
	rect:Draw()
end

---@deprecated Use RNDX.Rect(...):Rad(r):Material(mat):Draw() instead.
function RNDX.DrawMaterial(r, x, y, w, h, col, mat, flags)
	local tex = mat:GetTexture("$basetexture")
	if tex then
		return RNDX.DrawTexture(r, x, y, w, h, col, tex, flags)
	end
end

---@deprecated Use RNDX.Circle(x, y, radius):Draw() instead. NOTE: legacy `r` is a DIAMETER, new API takes a RADIUS.
function RNDX.DrawCircle(x, y, r, col, flags)
	if col and col.a == 0 then return end
	local c = RNDX.Circle(x, y, r / 2)
	if col then c:Color(col) end
	if flags then c:Flags(flags) end
	c:Draw()
end

---@deprecated Use RNDX.Circle(x, y, radius):Outline(thickness):Draw() instead. Legacy `r` is a DIAMETER.
function RNDX.DrawCircleOutlined(x, y, r, col, thickness, flags)
	if col and col.a == 0 then return end
	local c = RNDX.Circle(x, y, r / 2):Outline(thickness or 1)
	if col then c:Color(col) end
	if flags then c:Flags(flags) end
	c:Draw()
end

---@deprecated Use RNDX.Circle(x, y, radius):Texture(texture):Draw() instead. Legacy `r` is a DIAMETER.
function RNDX.DrawCircleTexture(x, y, r, col, texture, flags)
	if col and col.a == 0 then return end
	local c = RNDX.Circle(x, y, r / 2):Texture(texture)
	if col then c:Color(col) end
	if flags then c:Flags(flags) end
	c:Draw()
end

---@deprecated Use RNDX.Circle(x, y, radius):Material(mat):Draw() instead. Legacy `r` is a DIAMETER.
function RNDX.DrawCircleMaterial(x, y, r, col, mat, flags)
	if col and col.a == 0 then return end
	local c = RNDX.Circle(x, y, r / 2):Material(mat)
	if col then c:Color(col) end
	if flags then c:Flags(flags) end
	c:Draw()
end

---@deprecated Use RNDX.Rect(...):Radii(tl, tr, bl, br):Blur(intensity):Draw() instead.
function RNDX.DrawBlur(x, y, w, h, flags, tl, tr, bl, br, thickness)
	local rect = RNDX.Rect(x, y, w, h):Radii(tl, tr, bl, br):Blur()
	if thickness then rect:Outline(thickness) end
	if flags then rect:Flags(flags) end
	rect:Draw()
end

---@deprecated Use RNDX.Rect(...):Radii(...):Shadow(blur, spread, ox, oy):Draw() instead. Visuals are approximated, not identical.
function RNDX.DrawShadowsEx(x, y, w, h, col, flags, tl, tr, bl, br, spread, intensity, thickness)
	if col and col.a == 0 then return end
	spread = spread or 30
	local rect = RNDX.Rect(x, y, w, h)
		:Radii(tl, tr, bl, br)
		:Shadow(intensity or (spread * 1.2), spread)
	if thickness then rect:Outline(thickness) end
	if col then rect:Color(col) end
	if flags then rect:Flags(flags) end
	rect:Draw()
end

---@deprecated Use RNDX.Rect(...):Rad(r):Shadow(blur, spread, ox, oy):Draw() instead. Visuals are approximated, not identical.
function RNDX.DrawShadows(r, x, y, w, h, col, spread, intensity, flags)
	return RNDX.DrawShadowsEx(x, y, w, h, col, flags, r, r, r, r, spread, intensity)
end

---@deprecated Use RNDX.Rect(...):Rad(r):Outline(thickness):Shadow(...):Draw() instead. Visuals are approximated, not identical.
function RNDX.DrawShadowsOutlined(r, x, y, w, h, col, thickness, spread, intensity, flags)
	return RNDX.DrawShadowsEx(x, y, w, h, col, flags, r, r, r, r, spread, intensity, thickness or 1)
end

-- Legacy RNDX() call style
local LEGACY_TYPES = {
	Rect = RNDX.Rect,
	---@deprecated Legacy Circle(x, y, size) treats `size` as a DIAMETER; RNDX.Circle takes a radius.
	Circle = function(x, y, r)
		return RNDX.Circle(x, y, r / 2)
	end,
}

setmetatable(RNDX, {
	---@deprecated Use RNDX.Rect(...) / RNDX.Circle(...) directly instead of RNDX().Rect(...).
	__call = function()
		return LEGACY_TYPES
	end
})

return RNDX
