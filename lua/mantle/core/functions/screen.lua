function Mantle.func.w(px)
    local cached = Mantle.func.w_save[px]
    if !cached then
        cached = px / 1920 * Mantle.func.sw
        Mantle.func.w_save[px] = cached
    end

    return cached
end

function Mantle.func.h(px)
    local cached = Mantle.func.h_save[px]
    if !cached then
        cached = px / 1080 * Mantle.func.sh
        Mantle.func.h_save[px] = cached
    end

    return cached
end

hook.Add('OnScreenSizeChanged', 'Mantle', function()
    local newW, newH = ScrW(), ScrH()
    if newW == Mantle.func.sw and newH == Mantle.func.sh then return end

    Mantle.func.sw, Mantle.func.sh = newW, newH
    Mantle.func.w_save = {}
    Mantle.func.h_save = {}
end)
