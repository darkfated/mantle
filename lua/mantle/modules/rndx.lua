--[[
Copyright (c) 2025 Srlion (https://github.com/Srlion)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

-- Modified version of RNDX for the Mantle library:
-- https://github.com/darkfated/mantle/blob/master/lua/mantle/modules/rndx.lua

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
local render_PushRenderTarget = render.PushRenderTarget
local render_PopRenderTarget = render.PopRenderTarget
local cam_Start2D = cam.Start2D
local cam_End2D = cam.End2D
local math_min = math.min
local math_max = math.max
local math_ceil = math.ceil
local DisableClipping = DisableClipping
local type = type
local tobool = tobool

local RNDX = {}

-- ============================================================
--                        SHADERS
-- ============================================================

local SHADERS_VERSION = "1786919644"
local SHADERS_GMA = [========[R01BRAOHS2tdVNwrANw6gmoAAAAAAFJORFhfMTc4NjkxOTY0NAAAdW5rbm93bgABAAAAAQAAAHNoYWRlcnMvZnhjLzE3ODY5MTk2NDRfbWFudGxlX2thd2FzZV9kb3duX3BzMzAudmNzAIQBAAAAAAAAAAAAAAIAAABzaGFkZXJzL2Z4Yy8xNzg2OTE5NjQ0X21hbnRsZV9rYXdhc2VfcHMzMC52Y3MAdAQAAAAAAAAAAAAAAwAAAHNoYWRlcnMvZnhjLzE3ODY5MTk2NDRfbWFudGxlX2thd2FzZV91cF9wczMwLnZjcwC2AQAAAAAAAAAAAAAEAAAAc2hhZGVycy9meGMvMTc4NjkxOTY0NF9tYW50bGVfcm91bmRlZF9ibHVyX3BzMzAudmNzAKMFAAAAAAAAAAAAAAUAAABzaGFkZXJzL2Z4Yy8xNzg2OTE5NjQ0X21hbnRsZV9yb3VuZGVkX3JlY3RfcHMzMC52Y3MAhAQAAAAAAAAAAAAABgAAAHNoYWRlcnMvZnhjLzE3ODY5MTk2NDRfbWFudGxlX3NoYWRvd19ibHVyX3BzMzAudmNzALcJAAAAAAAAAAAAAAcAAABzaGFkZXJzL2Z4Yy8xNzg2OTE5NjQ0X21hbnRsZV9zaGFkb3dfcHMzMC52Y3MAgwgAAAAAAAAAAAAACAAAAHNoYWRlcnMvZnhjLzE3ODY5MTk2NDRfbWFudGxlX3ZlcnRleF9nYW1tYV92czMwLnZjcwBRAQAAAAAAAAAAAAAJAAAAc2hhZGVycy9meGMvMTc4NjkxOTY0NF9tYW50bGVfdmVydGV4X3NjcmVlbl92czMwLnZjcwAeAQAAAAAAAAAAAAAAAAAABgAAAAEAAAABAAAAAAAAAAAAAAACAAAAJxCl9gAAAAAwAAAA/////4QBAAAAAAAATAEAQExaTUFAAgAAOwEAAF0AAAABAABojF4Yhr/sqSfFxN+zZLlNu81j3IcIAhToGS5UZxoAkgPpTvY8RG3Izb0NZlQqwWgiMXe3bXTIandISKQ7mP1/8kqRZKHCz8GsWd1gHXapz98+0Yg5lff0pVu9cip/gJaf/GwvYxbSrHs7J2rtAaHapKo+L1N/q9jV50BUK4w4CsBuMBpPwuCwIKzlzqx9KqAbAji3vqQCPoxDNoVuZKIgx7HmokMjkf3Q5hp+zQxCTAVm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]========]
do
	local decoded = util.Base64Decode(SHADERS_GMA)
	if not decoded or #decoded == 0 then
		print("Failed to load shaders!")
		return
	end

	file.Write("rndx_shaders_" .. SHADERS_VERSION .. ".gma", decoded)
	game.MountGMA("data/rndx_shaders_" .. SHADERS_VERSION .. ".gma")
end

local function GET_SHADER(name)
	return SHADERS_VERSION:gsub("%.", "_") .. "_" .. name
end

-- ============================================================
--                      RENDER TARGET
-- ============================================================

local BLUR_RT = GetRenderTargetEx("RNDX" .. SHADERS_VERSION .. SysTime(),
	1024, 1024,
	RT_SIZE_LITERAL,
	MATERIAL_RT_DEPTH_SEPARATE,
	bit.bor(2, 256, 4, 8),
	0,
	IMAGE_FORMAT_BGRA8888
)

local KB_RT_SIZES = { 1024, 512, 256, 128, 64 }
local KB_RTS = { BLUR_RT }
for i = 2, #KB_RT_SIZES do
	KB_RTS[i] = GetRenderTargetEx("RNDX_KB" .. (i - 1) .. SHADERS_VERSION .. SysTime(),
		KB_RT_SIZES[i], KB_RT_SIZES[i],
		RT_SIZE_LITERAL,
		MATERIAL_RT_DEPTH_SEPARATE,
		bit.bor(2, 256, 4, 8),
		0,
		IMAGE_FORMAT_BGRA8888
	)
end
local MAX_KB_LEVELS = #KB_RT_SIZES - 1

-- ============================================================
--                        CONSTANTS
-- ============================================================

local NEW_FLAG; do
	local flags_n = -1
	function NEW_FLAG()
		flags_n = flags_n + 1
		return 2 ^ flags_n
	end
end

local NO_TL, NO_TR, NO_BL, NO_BR = NEW_FLAG(), NEW_FLAG(), NEW_FLAG(), NEW_FLAG()
local SHAPE_CIRCLE, SHAPE_FIGMA, SHAPE_IOS = NEW_FLAG(), NEW_FLAG(), NEW_FLAG()
local BLUR = NEW_FLAG()
local KBLUR = NEW_FLAG()
local MANUAL_COLOR = NEW_FLAG()

local SHAPES = {
	[SHAPE_CIRCLE] = 2,
	[SHAPE_FIGMA] = 2.2,
	[SHAPE_IOS] = 4,
}

local DEFAULT_SHAPE = SHAPE_FIGMA
local DEFAULT_BLUR_INTENSITY = 1.0
local DEFAULT_KB_ITERATIONS = 4

local BLUR_VERTICAL = "$c0_x"
local KB_OFFSET_C = "$c0_x"
local SHADOW_OX_C, SHADOW_OY_C = "$c0_y", "$c0_z"

local FLAG_FADE_TOP = 8
local FLAG_FADE_BOTTOM = 16

-- ============================================================
--                        MATERIALS
-- ============================================================

local BASE_VMT = [==[
screenspace_general
{
	$pixshader ""
	$vertexshader ""

	$basetexture ""
	$texture1    ""
	$texture2    ""
	$texture3    ""

	$ignorez            1
	$vertexcolor        1
	$vertextransform    1
	"<dx90"
	{
		$no_draw 1
	}

	$copyalpha                 0
	$alpha_blend_color_overlay 0
	$alpha_blend               1
}
]==]

local LINEAR_KVS = {
	["$linearwrite"] = 1,
	["$linearread_basetexture"] = 1,
	["$linearread_texture1"] = 1,
	["$linearread_texture2"] = 1,
	["$linearread_texture3"] = 1,
}

local MATRIXES = {}

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

local LEGACY_GAMMA = false

local ROUNDED_MAT, ROUNDED_TEXTURE_MAT, ROUNDED_BLUR_MAT, KBLUR_MAT, KB_DOWN_MAT, KB_UP_MAT, SHADOWS_MAT, SHADOWS_BLUR_MAT

local function create_materials()
	local vs = GET_SHADER(LEGACY_GAMMA and "mantle_vertex_gamma_vs30" or "mantle_vertex_screen_vs30")
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
		["$pixshader"] = GET_SHADER("mantle_rounded_rect_ps30"),
	})
	ROUNDED_TEXTURE_MAT = make("rounded_texture", {
		["$pixshader"] = GET_SHADER("mantle_rounded_rect_ps30"),
		["$basetexture"] = "loveyoumom",
	})
	ROUNDED_BLUR_MAT = make("blur", {
		["$pixshader"] = GET_SHADER("mantle_rounded_blur_ps30"),
		["$basetexture"] = BLUR_RT:GetName(),
		["$texture1"] = "_rt_FullFrameFB",
	})
	KBLUR_MAT = make("kblur", {
		["$pixshader"] = GET_SHADER("mantle_kawase_ps30"),
		["$basetexture"] = BLUR_RT:GetName(),
		["$texture1"] = "_rt_FullFrameFB",
	})
	KB_DOWN_MAT = make("kawase_down", {
		["$pixshader"] = GET_SHADER("mantle_kawase_down_ps30"),
		["$basetexture"] = BLUR_RT:GetName(),
	})
	KB_UP_MAT = make("kawase_up", {
		["$pixshader"] = GET_SHADER("mantle_kawase_up_ps30"),
		["$basetexture"] = BLUR_RT:GetName(),
	})
	SHADOWS_MAT = make("rounded_shadows", {
		["$pixshader"] = GET_SHADER("mantle_shadow_ps30"),
	})
	SHADOWS_BLUR_MAT = make("shadows_blur", {
		["$pixshader"] = GET_SHADER("mantle_shadow_blur_ps30"),
		["$basetexture"] = BLUR_RT:GetName(),
		["$texture1"] = "_rt_FullFrameFB",
	})
end

create_materials()

local MATERIAL_SetTexture = ROUNDED_MAT.SetTexture
local MATERIAL_SetMatrix = ROUNDED_MAT.SetMatrix
local MATERIAL_SetFloat = ROUNDED_MAT.SetFloat
local MATRIX_SetUnpacked = Matrix().SetUnpacked

-- ============= DRAW STATE =============

local MAT
local X, Y, W, H
local TL, TR, BL, BR
local TEXTURE
local USING_BLUR, BLUR_INTENSITY, BLUR_ALPHA
local USING_KB, KB_ITERATIONS
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
	USING_KB, KB_ITERATIONS = false, DEFAULT_KB_ITERATIONS
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

-- ============================================================
--                        DRAWING
-- ============================================================

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
	if TEXTURE then flags_f = flags_f + 1 end
	if FADE_FLAG ~= 0 then flags_f = flags_f + FADE_FLAG end

	local start_rad, sweep_rad
	local sweep = END_ANGLE - START_ANGLE
	if sweep >= 360 then
		start_rad, sweep_rad = 0, -1
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

local function draw_rt(src, dst, mat, w, h, offset)
	MATERIAL_SetTexture(mat, "$basetexture", src)
	MATERIAL_SetFloat(mat, KB_OFFSET_C, offset)

	render_PushRenderTarget(dst, 0, 0, w, h)
	cam_Start2D()
	surface_SetMaterial(mat)
	surface_DrawTexturedRect(0, 0, w, h)
	cam_End2D()
	render_PopRenderTarget()
end

local function draw_kblur()
	MAT = KBLUR_MAT

	COL_R, COL_G, COL_B, COL_A = 255, 255, 255, 255
	SetupDraw()

	local levels = math_min(KB_ITERATIONS, MAX_KB_LEVELS)

	render_CopyRenderTargetToTexture(BLUR_RT)

	for i = 1, levels do
		draw_rt(KB_RTS[i], KB_RTS[i + 1], KB_DOWN_MAT, KB_RT_SIZES[i + 1], KB_RT_SIZES[i + 1], BLUR_INTENSITY)
	end

	for i = levels, 1, -1 do
		draw_rt(KB_RTS[i + 1], KB_RTS[i], KB_UP_MAT, KB_RT_SIZES[i], KB_RT_SIZES[i], BLUR_INTENSITY)
	end

	SetupDraw()
	surface_DrawTexturedRect(X, Y, W, H)
end

local function setup_shadows()
	TL, TR, BL, BR = normalize_corner_radii()
	RADII_NORMALIZED = true

	if SHADOW_SPREAD < 0 then
		local min_half = math_min(W, H) * 0.5
		if -SHADOW_SPREAD > min_half then SHADOW_SPREAD = -min_half end
	end

	if SHADOW_SPREAD ~= 0 then
		X = X - SHADOW_SPREAD
		Y = Y - SHADOW_SPREAD
		W = W + SHADOW_SPREAD * 2
		H = H + SHADOW_SPREAD * 2
	end

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

-- ============================================================
--                        BUILDER
-- ============================================================

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
	KBlur = function(self, iterations, radius)
		USING_KB = true
		KB_ITERATIONS = math_max(1, math_min(math.floor(iterations or DEFAULT_KB_ITERATIONS), MAX_KB_LEVELS))
		BLUR_INTENSITY = math_max(radius or DEFAULT_BLUR_INTENSITY, 0)
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
	StartAngle = function(self, angle)
		START_ANGLE = angle or 0
		return self
	end,
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

		if bit_band(flags, NO_TL) ~= 0 then TL = 0 end
		if bit_band(flags, NO_TR) ~= 0 then TR = 0 end
		if bit_band(flags, NO_BL) ~= 0 then BL = 0 end
		if bit_band(flags, NO_BR) ~= 0 then BR = 0 end

		local shape_flag = bit_band(flags, SHAPE_CIRCLE + SHAPE_FIGMA + SHAPE_IOS)
		if shape_flag ~= 0 then
			SHAPE = SHAPES[shape_flag] or SHAPES[DEFAULT_SHAPE]
		end

		if bit_band(flags, BLUR) ~= 0 then
			BASE_FUNCS.Blur(self)
		end

		if bit_band(flags, KBLUR) ~= 0 then
			BASE_FUNCS.KBlur(self)
		end

		if bit_band(flags, MANUAL_COLOR) ~= 0 then
			COL_R = nil
		end

		return self
	end,

	Draw = function(self)
		if END_ANGLE == START_ANGLE then
			return
		end

		local OLD_CLIPPING_STATE
		if SHADOW_ENABLED or CLIP_PANEL then
			OLD_CLIPPING_STATE = DisableClipping(true)
		end

		if CLIP_PANEL then
			local sx, sy = CLIP_PANEL:LocalToScreen(0, 0)
			local sw, sh = CLIP_PANEL:GetSize()
			render.SetScissorRect(sx, sy, sx + sw, sy + sh, true)
		end

		if SHADOW_ENABLED then
			if not COL_SET then
				COL_R, COL_G, COL_B, COL_A = 0, 0, 0, 255
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
		elseif USING_KB then
			setup_pad()
			draw_kblur()
		else
			setup_pad()
			if TEXTURE then
				MAT = ROUNDED_TEXTURE_MAT
				MATERIAL_SetTexture(MAT, "$basetexture", TEXTURE)
			end

			SetupDraw()
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
		if SHADOW_ENABLED or USING_BLUR or USING_KB then
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
	if k ~= "Rad" and k ~= "Radii" then
		CIRCLE[k] = v
	end
end

-- ============================================================
--                          API
-- ============================================================

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

function RNDX.SetDefaultKBlurIterations(val)
	DEFAULT_KB_ITERATIONS = math_max(1, math_min(math.floor(tonumber(val) or 4), MAX_KB_LEVELS))
end

function RNDX.GetDefaultKBlurIterations()
	return DEFAULT_KB_ITERATIONS
end

RNDX.NO_TL = NO_TL
RNDX.NO_TR = NO_TR
RNDX.NO_BL = NO_BL
RNDX.NO_BR = NO_BR

RNDX.SHAPE_CIRCLE = SHAPE_CIRCLE
RNDX.SHAPE_FIGMA = SHAPE_FIGMA
RNDX.SHAPE_IOS = SHAPE_IOS

RNDX.BLUR = BLUR
RNDX.KBLUR = KBLUR
RNDX.MANUAL_COLOR = MANUAL_COLOR

function RNDX.SetFlag(flags, flag, bool)
	flag = RNDX[flag] or flag
	if tobool(bool) then
		return bit.bor(flags, flag)
	else
		return bit.band(flags, bit.bnot(flag))
	end
end

-- ============================================================
--                       LEGACY API
-- ============================================================

function RNDX.Draw(r, x, y, w, h, col, flags)
	if col and col.a == 0 then return end
	local rect = RNDX.Rect(x, y, w, h):Rad(r)
	if col then rect:Color(col) end
	if flags then rect:Flags(flags) end
	rect:Draw()
end

function RNDX.DrawOutlined(r, x, y, w, h, col, thickness, flags)
	if col and col.a == 0 then return end
	local rect = RNDX.Rect(x, y, w, h):Rad(r):Outline(thickness or 1)
	if col then rect:Color(col) end
	if flags then rect:Flags(flags) end
	rect:Draw()
end

function RNDX.DrawTexture(r, x, y, w, h, col, texture, flags)
	if col and col.a == 0 then return end
	local rect = RNDX.Rect(x, y, w, h):Rad(r):Texture(texture)
	if col then rect:Color(col) end
	if flags then rect:Flags(flags) end
	rect:Draw()
end

function RNDX.DrawMaterial(r, x, y, w, h, col, mat, flags)
	local tex = mat:GetTexture("$basetexture")
	if tex then
		return RNDX.DrawTexture(r, x, y, w, h, col, tex, flags)
	end
end

function RNDX.DrawCircle(x, y, r, col, flags)
	if col and col.a == 0 then return end
	local c = RNDX.Circle(x, y, r / 2)
	if col then c:Color(col) end
	if flags then c:Flags(flags) end
	c:Draw()
end

function RNDX.DrawCircleOutlined(x, y, r, col, thickness, flags)
	if col and col.a == 0 then return end
	local c = RNDX.Circle(x, y, r / 2):Outline(thickness or 1)
	if col then c:Color(col) end
	if flags then c:Flags(flags) end
	c:Draw()
end

function RNDX.DrawCircleTexture(x, y, r, col, texture, flags)
	if col and col.a == 0 then return end
	local c = RNDX.Circle(x, y, r / 2):Texture(texture)
	if col then c:Color(col) end
	if flags then c:Flags(flags) end
	c:Draw()
end

function RNDX.DrawCircleMaterial(x, y, r, col, mat, flags)
	if col and col.a == 0 then return end
	local c = RNDX.Circle(x, y, r / 2):Material(mat)
	if col then c:Color(col) end
	if flags then c:Flags(flags) end
	c:Draw()
end

function RNDX.DrawBlur(x, y, w, h, flags, tl, tr, bl, br, thickness)
	local rect = RNDX.Rect(x, y, w, h):Radii(tl, tr, bl, br):Blur()
	if thickness then rect:Outline(thickness) end
	if flags then rect:Flags(flags) end
	rect:Draw()
end

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

function RNDX.DrawShadows(r, x, y, w, h, col, spread, intensity, flags)
	return RNDX.DrawShadowsEx(x, y, w, h, col, flags, r, r, r, r, spread, intensity)
end

function RNDX.DrawShadowsOutlined(r, x, y, w, h, col, thickness, spread, intensity, flags)
	return RNDX.DrawShadowsEx(x, y, w, h, col, flags, r, r, r, r, spread, intensity, thickness or 1)
end

local LEGACY_TYPES = {
	Rect = RNDX.Rect,
	Circle = function(x, y, r)
		return RNDX.Circle(x, y, r / 2)
	end,
}

setmetatable(RNDX, {
	__call = function()
		return LEGACY_TYPES
	end
})

return RNDX
