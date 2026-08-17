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

local SHADERS_VERSION = "1786935820"
local SHADERS_GMA = [========[R01BRAOHS2tdVNwrAAx6gmoAAAAAAFJORFhfMTc4NjkzNTgyMAAAdW5rbm93bgABAAAAAQAAAHNoYWRlcnMvZnhjLzE3ODY5MzU4MjBfbWFudGxlX2thd2FzZV9kb3duX3BzMzAudmNzAIQBAAAAAAAAAAAAAAIAAABzaGFkZXJzL2Z4Yy8xNzg2OTM1ODIwX21hbnRsZV9rYXdhc2VfcHMzMC52Y3MAlgQAAAAAAAAAAAAAAwAAAHNoYWRlcnMvZnhjLzE3ODY5MzU4MjBfbWFudGxlX2thd2FzZV91cF9wczMwLnZjcwC2AQAAAAAAAAAAAAAEAAAAc2hhZGVycy9meGMvMTc4NjkzNTgyMF9tYW50bGVfcm91bmRlZF9ibHVyX3BzMzAudmNzAMcFAAAAAAAAAAAAAAUAAABzaGFkZXJzL2Z4Yy8xNzg2OTM1ODIwX21hbnRsZV9yb3VuZGVkX3JlY3RfcHMzMC52Y3MAsAQAAAAAAAAAAAAABgAAAHNoYWRlcnMvZnhjLzE3ODY5MzU4MjBfbWFudGxlX3NoYWRvd19ibHVyX3BzMzAudmNzAM8JAAAAAAAAAAAAAAcAAABzaGFkZXJzL2Z4Yy8xNzg2OTM1ODIwX21hbnRsZV9zaGFkb3dfcHMzMC52Y3MAawgAAAAAAAAAAAAACAAAAHNoYWRlcnMvZnhjLzE3ODY5MzU4MjBfbWFudGxlX3ZlcnRleF9nYW1tYV92czMwLnZjcwBRAQAAAAAAAAAAAAAJAAAAc2hhZGVycy9meGMvMTc4NjkzNTgyMF9tYW50bGVfdmVydGV4X3NjcmVlbl92czMwLnZjcwAeAQAAAAAAAAAAAAAAAAAABgAAAAEAAAABAAAAAAAAAAAAAAACAAAAJxCl9gAAAAAwAAAA/////4QBAAAAAAAATAEAQExaTUFAAgAAOwEAAF0AAAABAABojF4Yhr/sqSfFxN+zZLlNu81j3IcIAhToGS5UZxoAkgPpTvY8RG3Izb0NZlQqwWgiMXe3bXTIandISKQ7mP1/8kqRZKHCz8GsWd1gHXapz98+0Yg5lff0pVu9cip/gJaf/GwvYxbSrHs7J2rtAaHapKo+L1N/q9jV50BUK4w4CsBuMBpPwuCwIKzlzqx9KqAbAji3vqQCPoxDNoVuZKIgx7HmokMjkf3Q5hp+zQxCTAVm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]========]
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

	if COL_R ~= nil then
		surface_SetDrawColor(COL_R, COL_G, COL_B, COL_A)
	end

	surface_SetMaterial(MAT)
end

local function draw_blur(shadow)
	MAT = shadow and SHADOWS_BLUR_MAT or ROUNDED_BLUR_MAT

	local r, g, b, a = COL_R, COL_G, COL_B, COL_A
	COL_R, COL_G, COL_B, COL_A = 255, 255, 255, math.floor(255 * BLUR_ALPHA)
	SetupDraw()

	render_CopyRenderTargetToTexture(BLUR_RT)
	MATERIAL_SetFloat(MAT, BLUR_VERTICAL, 0)
	surface_DrawTexturedRect(X, Y, W, H)

	render_CopyRenderTargetToTexture(BLUR_RT)
	MATERIAL_SetFloat(MAT, BLUR_VERTICAL, 1)
	surface_DrawTexturedRect(X, Y, W, H)

	COL_R, COL_G, COL_B, COL_A = r, g, b, a
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

	local r, g, b, a = COL_R, COL_G, COL_B, COL_A
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

	COL_R, COL_G, COL_B, COL_A = r, g, b, a
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
