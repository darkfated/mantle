local function create_shadows()
    local scrw, scrh = ScrW(), ScrH()

    BSHADOWS = {}

    local resStr = scrw .. scrh

    BSHADOWS.RenderTarget = GetRenderTarget('bshadows_original_' .. resStr, scrw, scrh)
    BSHADOWS.RenderTarget2 = GetRenderTarget('bshadows_shadow_' .. resStr, scrw, scrh)
    BSHADOWS.ShadowMaterial = CreateMaterial('bshadows', 'UnlitGeneric', {
        ['$translucent'] = 1,
        ['$vertexalpha'] = 1,
        ['alpha'] = 1
    })

    BSHADOWS.ShadowMaterialGrayscale = CreateMaterial('bshadows_grayscale', 'UnlitGeneric', {
        ['$translucent'] = 1,
        ['$vertexalpha'] = 1,
        ['$alpha'] = 1,
        ['$color'] = '0 0 0',
        ['$color2'] = '0 0 0'
    })

    BSHADOWS.BeginShadow = function()
        render.PushRenderTarget(BSHADOWS.RenderTarget)

        render.OverrideAlphaWriteEnable(true, true)
        render.Clear(0, 0, 0, 0)
        render.OverrideAlphaWriteEnable(false, false)

        cam.Start2D()
    end

    BSHADOWS.EndShadow = function(intensity, spread, blur, opacity, direction, distance, _shadowOnly)
        opacity = opacity or 255
        direction = direction or 0
        distance = distance or 0
        _shadowOnly = _shadowOnly or false

        render.CopyRenderTargetToTexture(BSHADOWS.RenderTarget2)

        if blur > 0 then
            render.OverrideAlphaWriteEnable(true, true)
            render.BlurRenderTarget(BSHADOWS.RenderTarget2, spread, spread, blur)
            render.OverrideAlphaWriteEnable(false, false)
        end

        render.PopRenderTarget()

        BSHADOWS.ShadowMaterial:SetTexture('$basetexture', BSHADOWS.RenderTarget)
        BSHADOWS.ShadowMaterialGrayscale:SetTexture('$basetexture', BSHADOWS.RenderTarget2)

        local xOffset = math.sin(math.rad(direction)) * distance
        local yOffset = math.cos(math.rad(direction)) * distance

        BSHADOWS.ShadowMaterialGrayscale:SetFloat('$alpha', opacity / 255)
        render.SetMaterial(BSHADOWS.ShadowMaterialGrayscale)

        for i = 1, math.ceil(intensity) do
            render.DrawScreenQuadEx(xOffset, yOffset, scrw, scrh)
        end

        if !_shadowOnly then
            BSHADOWS.ShadowMaterial:SetTexture('$basetexture', BSHADOWS.RenderTarget)
            render.SetMaterial(BSHADOWS.ShadowMaterial)
            render.DrawScreenQuad()
        end

        cam.End2D()
    end

    BSHADOWS.DrawShadowTexture = function(texture, intensity, spread, blur, opacity, direction, distance, shadowOnly)
        opacity = opacity or 255
        direction = direction or 0
        distance = distance or 0
        shadowOnly = shadowOnly or false

        render.CopyTexture(texture, BSHADOWS.RenderTarget2)

        if blur > 0 then
            render.PushRenderTarget(BSHADOWS.RenderTarget2)
            render.OverrideAlphaWriteEnable(true, true)
            render.BlurRenderTarget(BSHADOWS.RenderTarget2, spread, spread, blur)
            render.OverrideAlphaWriteEnable(false, false)
            render.PopRenderTarget()
        end

        BSHADOWS.ShadowMaterialGrayscale:SetTexture('$basetexture', BSHADOWS.RenderTarget2)

        local xOffset = math.sin(math.rad(direction)) * distance
        local yOffset = math.cos(math.rad(direction)) * distance

        BSHADOWS.ShadowMaterialGrayscale:SetFloat('$alpha', opacity / 255)
        render.SetMaterial(BSHADOWS.ShadowMaterialGrayscale)

        for i = 1, math.ceil(intensity) do
            render.DrawScreenQuadEx(xOffset, yOffset, scrw, scrh)
        end

        if !shadowOnly then
            BSHADOWS.ShadowMaterial:SetTexture('$basetexture', texture)
            render.SetMaterial(BSHADOWS.ShadowMaterial)
            render.DrawScreenQuad()
        end
    end
end

create_shadows()

hook.Add('OnScreenSizeChanged', 'Mantle.Shadows', function()
    create_shadows()
end)
