function Mantle.func.sound(path)
    surface.PlaySound(path or 'mantle/btn_click.ogg')
end

function Mantle.func.ClampMenuPosition(panel)
    if not IsValid(panel) then return end

    local x, y = panel:GetPos()
    local w, h = panel:GetSize()
    local sw, sh = Mantle.func.sw, Mantle.func.sh

    if x < 5 then
        x = 5
    elseif x + w > sw - 5 then
        x = sw - 5 - w
    end

    if y < 5 then
        y = 5
    elseif y + h > sh - 5 then
        y = sh - 5 - h
    end

    panel:SetPos(x, y)
end
