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

local SHADERS_VERSION = "1786940851"
local SHADERS_GMA = [========[R01BRAOHS2tdVNwrALONgmoAAAAAAFJORFhfMTc4Njk0MDg1MQAAdW5rbm93bgABAAAAAQAAAHNoYWRlcnMvZnhjLzE3ODY5NDA4NTFfbWFudGxlX2FjcnlsaWNfcHMzMC52Y3MA8wUAAAAAAAAAAAAAAgAAAHNoYWRlcnMvZnhjLzE3ODY5NDA4NTFfbWFudGxlX2thd2FzZV9kb3duX3BzMzAudmNzAIQBAAAAAAAAAAAAAAMAAABzaGFkZXJzL2Z4Yy8xNzg2OTQwODUxX21hbnRsZV9rYXdhc2VfcHMzMC52Y3MAlgQAAAAAAAAAAAAABAAAAHNoYWRlcnMvZnhjLzE3ODY5NDA4NTFfbWFudGxlX2thd2FzZV91cF9wczMwLnZjcwC2AQAAAAAAAAAAAAAFAAAAc2hhZGVycy9meGMvMTc4Njk0MDg1MV9tYW50bGVfcm91bmRlZF9ibHVyX3BzMzAudmNzAMcFAAAAAAAAAAAAAAYAAABzaGFkZXJzL2Z4Yy8xNzg2OTQwODUxX21hbnRsZV9yb3VuZGVkX3JlY3RfcHMzMC52Y3MAsAQAAAAAAAAAAAAABwAAAHNoYWRlcnMvZnhjLzE3ODY5NDA4NTFfbWFudGxlX3NoYWRvd19ibHVyX3BzMzAudmNzAM8JAAAAAAAAAAAAAAgAAABzaGFkZXJzL2Z4Yy8xNzg2OTQwODUxX21hbnRsZV9zaGFkb3dfcHMzMC52Y3MAawgAAAAAAAAAAAAACQAAAHNoYWRlcnMvZnhjLzE3ODY5NDA4NTFfbWFudGxlX3ZlcnRleF9nYW1tYV92czMwLnZjcwBRAQAAAAAAAAAAAAAKAAAAc2hhZGVycy9meGMvMTc4Njk0MDg1MV9tYW50bGVfdmVydGV4X3NjcmVlbl92czMwLnZjcwAeAQAAAAAAAAAAAAAAAAAABgAAAAEAAAABAAAAAAAAAAAAAAACAAAA4tZvNAAAAAAwAAAA//////MFAAAAAAAAuwUAQExaTUGcEAAAqgUAAF0AAAABAABoo198f7/sqj/+eMp4JRdm72ukxt5p8rs/zYcfNXUYcEU/61jVBIacX3Bfp8EtWT/5dwMB4O1XYeEYBRtcWl8agEuMpgUIfv/e2SyTLSTxH0Ped9e7TeUyPg0d1EzziMT6DYxg9v9vTA263W0KC70HvA+k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]========]
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
	ACRYLIC_MAT = make("acrylic", {
		["$pixshader"] = GET_SHADER("mantle_acrylic_ps30"),
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
local USING_ACRYLIC
local ACRYLIC_BLUR, ACRYLIC_ITERATIONS, ACRYLIC_RADIUS
local ACRYLIC_BURN, ACRYLIC_BURN_COLOR, ACRYLIC_BURN_AMOUNT
local ACRYLIC_TINT, ACRYLIC_TINT_COLOR, ACRYLIC_TINT_AMOUNT
local ACRYLIC_NOISE, ACRYLIC_NOISE_INTENSITY, ACRYLIC_NOISE_SCALE
local ACRYLIC_FRESNEL, ACRYLIC_FRESNEL_COLOR, ACRYLIC_FRESNEL_AMOUNT, ACRYLIC_FRESNEL_WIDTH
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
	USING_ACRYLIC = false
	ACRYLIC_BLUR, ACRYLIC_ITERATIONS, ACRYLIC_RADIUS = true, 4, 2
	ACRYLIC_BURN, ACRYLIC_BURN_COLOR, ACRYLIC_BURN_AMOUNT = true, Color(120, 120, 120), 0.6
	ACRYLIC_TINT, ACRYLIC_TINT_COLOR, ACRYLIC_TINT_AMOUNT = true, Color(26, 28, 34), 0.55
	ACRYLIC_NOISE, ACRYLIC_NOISE_INTENSITY, ACRYLIC_NOISE_SCALE = true, 0.05, 4
	ACRYLIC_FRESNEL, ACRYLIC_FRESNEL_COLOR, ACRYLIC_FRESNEL_AMOUNT, ACRYLIC_FRESNEL_WIDTH = true, Color(255, 255, 255), 0.35, 0.4
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
	if USING_ACRYLIC then
		if ACRYLIC_BURN then flags_f = flags_f + 64 end
		if ACRYLIC_TINT then flags_f = flags_f + 128 end
		if ACRYLIC_NOISE then flags_f = flags_f + 256 end
		if ACRYLIC_FRESNEL then flags_f = flags_f + 512 end
	end

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

local function draw_acrylic()
	MAT = ACRYLIC_MAT

	local r, g, b, a = COL_R, COL_G, COL_B, COL_A
	COL_R, COL_G, COL_B, COL_A = 255, 255, 255, math.floor(255 * BLUR_ALPHA)
	SetupDraw()

	local levels = math_min(ACRYLIC_ITERATIONS, MAX_KB_LEVELS)

	render_CopyRenderTargetToTexture(BLUR_RT)

	if ACRYLIC_BLUR then
		for i = 1, levels do
			draw_rt(KB_RTS[i], KB_RTS[i + 1], KB_DOWN_MAT, KB_RT_SIZES[i + 1], KB_RT_SIZES[i + 1], ACRYLIC_RADIUS)
		end

		for i = levels, 1, -1 do
			draw_rt(KB_RTS[i + 1], KB_RTS[i], KB_UP_MAT, KB_RT_SIZES[i], KB_RT_SIZES[i], ACRYLIC_RADIUS)
		end
	end

	MATERIAL_SetFloat(MAT, "$c0_y", ACRYLIC_FRESNEL_WIDTH)
	MATERIAL_SetFloat(MAT, "$c0_z", ACRYLIC_NOISE_INTENSITY)
	MATERIAL_SetFloat(MAT, "$c0_w", ACRYLIC_NOISE_SCALE)

	MATERIAL_SetFloat(MAT, "$c1_x", ACRYLIC_BURN_COLOR.r / 255)
	MATERIAL_SetFloat(MAT, "$c1_y", ACRYLIC_BURN_COLOR.g / 255)
	MATERIAL_SetFloat(MAT, "$c1_z", ACRYLIC_BURN_COLOR.b / 255)
	MATERIAL_SetFloat(MAT, "$c1_w", ACRYLIC_BURN_AMOUNT)

	MATERIAL_SetFloat(MAT, "$c2_x", ACRYLIC_TINT_COLOR.r / 255)
	MATERIAL_SetFloat(MAT, "$c2_y", ACRYLIC_TINT_COLOR.g / 255)
	MATERIAL_SetFloat(MAT, "$c2_z", ACRYLIC_TINT_COLOR.b / 255)
	MATERIAL_SetFloat(MAT, "$c2_w", ACRYLIC_TINT_AMOUNT)

	MATERIAL_SetFloat(MAT, "$c3_x", ACRYLIC_FRESNEL_COLOR.r / 255)
	MATERIAL_SetFloat(MAT, "$c3_y", ACRYLIC_FRESNEL_COLOR.g / 255)
	MATERIAL_SetFloat(MAT, "$c3_z", ACRYLIC_FRESNEL_COLOR.b / 255)
	MATERIAL_SetFloat(MAT, "$c3_w", ACRYLIC_FRESNEL_AMOUNT)

	COL_R, COL_G, COL_B, COL_A = r, g, b, math.floor(a * BLUR_ALPHA)
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
	Acrylic = function(self, opts)
		USING_ACRYLIC = true
		if not opts then return self end

		local blur = opts.blur
		if blur ~= nil then
			if blur == false then
				ACRYLIC_BLUR = false
			else
				ACRYLIC_BLUR = true
				if blur.iterations then ACRYLIC_ITERATIONS = math_max(1, math_min(math.floor(blur.iterations), MAX_KB_LEVELS)) end
				if blur.radius then ACRYLIC_RADIUS = math_max(blur.radius, 0) end
			end
		end

		local burn = opts.burn
		if burn ~= nil then
			if burn == false then
				ACRYLIC_BURN = false
			else
				ACRYLIC_BURN = true
				if burn.color then ACRYLIC_BURN_COLOR = burn.color end
				if burn.amount then ACRYLIC_BURN_AMOUNT = burn.amount end
			end
		end

		local tint = opts.tint
		if tint ~= nil then
			if tint == false then
				ACRYLIC_TINT = false
			else
				ACRYLIC_TINT = true
				if tint.color then ACRYLIC_TINT_COLOR = tint.color end
				if tint.amount then ACRYLIC_TINT_AMOUNT = tint.amount end
			end
		end

		local noise = opts.noise
		if noise ~= nil then
			if noise == false then
				ACRYLIC_NOISE = false
			else
				ACRYLIC_NOISE = true
				if noise.intensity then ACRYLIC_NOISE_INTENSITY = math_max(noise.intensity, 0) end
				if noise.scale then ACRYLIC_NOISE_SCALE = math_max(noise.scale, 0.0001) end
			end
		end

		local fresnel = opts.fresnel
		if fresnel ~= nil then
			if fresnel == false then
				ACRYLIC_FRESNEL = false
			else
				ACRYLIC_FRESNEL = true
				if fresnel.color then ACRYLIC_FRESNEL_COLOR = fresnel.color end
				if fresnel.amount then ACRYLIC_FRESNEL_AMOUNT = fresnel.amount end
				if fresnel.width then ACRYLIC_FRESNEL_WIDTH = fresnel.width end
			end
		end

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
		elseif USING_ACRYLIC then
			setup_pad()
			draw_acrylic()
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
