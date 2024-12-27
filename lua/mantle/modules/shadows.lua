local math_sin = math.sin
local math_cos = math.cos
local math_rad = math.rad
local math_ceil = math.ceil

local function CreateBShadows()
    BShadows = {}

    local resStr = Mantle.func.sw .. Mantle.func.sh

    BShadows.RenderTarget = GetRenderTarget('BShadows_original_' .. resStr, Mantle.func.sw, Mantle.func.sh)
    BShadows.RenderTarget2 = GetRenderTarget('BShadows_shadow_' .. resStr, Mantle.func.sw, Mantle.func.sh)
    BShadows.ShadowMaterial = CreateMaterial('BShadows', 'UnlitGeneric', {
        ['$translucent'] = 1,
        ['$vertexalpha'] = 1,
        ['alpha'] = 1
    })

    BShadows.ShadowMaterialGrayscale = CreateMaterial('BShadows_grayscale', 'UnlitGeneric', {
        ['$translucent'] = 1,
        ['$vertexalpha'] = 1,
        ['$alpha'] = 1,
        ['$color'] = '0 0 0',
        ['$color2'] = '0 0 0'
    })

    BShadows.BeginShadow = function()
        render.PushRenderTarget(BShadows.RenderTarget)

        render.OverrideAlphaWriteEnable(true, true)
        render.Clear(0, 0, 0, 0)
        render.OverrideAlphaWriteEnable(false, false)

        cam.Start2D()
    end

    BShadows.EndShadow = function(intensity, spread, blur, opacity, direction, distance, bool_shadow_only)
        opacity = opacity or 255
        direction = direction or 0
        distance = distance or 0
        bool_shadow_only = bool_shadow_only or false

        render.CopyRenderTargetToTexture(BShadows.RenderTarget2)

        if blur > 0 then
            render.OverrideAlphaWriteEnable(true, true)
            render.BlurRenderTarget(BShadows.RenderTarget2, spread, spread, blur)
            render.OverrideAlphaWriteEnable(false, false)
        end

        render.PopRenderTarget()

        BShadows.ShadowMaterial:SetTexture('$basetexture', BShadows.RenderTarget)
        BShadows.ShadowMaterialGrayscale:SetTexture('$basetexture', BShadows.RenderTarget2)

        local xOffset = math_sin(math_rad(direction)) * distance
        local yOffset = math_cos(math_rad(direction)) * distance

        BShadows.ShadowMaterialGrayscale:SetFloat('$alpha', opacity / 255)
        render.SetMaterial(BShadows.ShadowMaterialGrayscale)

        for i = 1, math_ceil(intensity) do
            render.DrawScreenQuadEx(xOffset, yOffset, Mantle.func.sw, Mantle.func.sh)
        end

        if !bool_shadow_only then
            BShadows.ShadowMaterial:SetTexture('$basetexture', BShadows.RenderTarget)
            render.SetMaterial(BShadows.ShadowMaterial)
            render.DrawScreenQuad()
        end

        cam.End2D()
    end

    BShadows.DrawShadowTexture = function(texture, intensity, spread, blur, opacity, direction, distance, bool_shadow_only)
        opacity = opacity or 255
        direction = direction or 0
        distance = distance or 0
        bool_shadow_only = bool_shadow_only or false

        render.CopyTexture(texture, BShadows.RenderTarget2)

        if blur > 0 then
            render.PushRenderTarget(BShadows.RenderTarget2)
            render.OverrideAlphaWriteEnable(true, true)
            render.BlurRenderTarget(BShadows.RenderTarget2, spread, spread, blur)
            render.OverrideAlphaWriteEnable(false, false)
            render.PopRenderTarget()
        end

        BShadows.ShadowMaterialGrayscale:SetTexture('$basetexture', BShadows.RenderTarget2)

        local xOffset = math_sin(math_rad(direction)) * distance
        local yOffset = math_cos(math_rad(direction)) * distance

        BShadows.ShadowMaterialGrayscale:SetFloat('$alpha', opacity / 255)
        render.SetMaterial(BShadows.ShadowMaterialGrayscale)

        for i = 1, math_ceil(intensity) do
            render.DrawScreenQuadEx(xOffset, yOffset, Mantle.func.sw, Mantle.func.sh)
        end

        if !bool_shadow_only then
            BShadows.ShadowMaterial:SetTexture('$basetexture', texture)
            render.SetMaterial(BShadows.ShadowMaterial)
            render.DrawScreenQuad()
        end
    end
end

CreateBShadows()

hook.Add('OnScreenSizeChanged', 'Mantle.Shadows', function()
    CreateBShadows()
end)
