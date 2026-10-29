local mat_blur = Material('pp/blurscreen')
local mat_gradients = {
    Material('vgui/gradient_up'),
    Material('vgui/gradient_down'),
    Material('vgui/gradient-l'),
    Material('vgui/gradient-r')
}

function Mantle.func.blur(panel)
    local x, y = panel:LocalToScreen(0, 0)

    surface.SetDrawColor(color_white)
    surface.SetMaterial(mat_blur)

    for i = 1, 6 do
        mat_blur:SetFloat('$blur', i)
        mat_blur:Recompute()

        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(-x, -y, Mantle.func.sw, Mantle.func.sh)
    end
end

function Mantle.func.gradient(x, y, w, h, direction, color, radius, flags)
    local rect = RNDX.Rect(x, y, w, h)
        :Rad(radius or 0)
        :Material(mat_gradients[direction])
        :Color(color)
    if flags then rect:Flags(flags) end
    rect:Draw()
end

local function drawEntText(text, y)
    surface.SetFont('Fated.40')
    local tw, th = surface.GetTextSize(text)
    local bx, by = -tw * 0.5 - 18, y - 12
    local bw, bh = tw + 36, th + 24

    RNDX.Rect(bx, by, bw, bh - 6)
        :Radii(16, 16, 0, 0)
        :Blur()
    :Draw()
    RNDX.Rect(bx, by, bw, bh - 6)
        :Radii(16, 16, 0, 0)
        :Color(Mantle.color.background_alpha)
    :Draw()
    RNDX.Rect(bx, by + bh - 6, bw, 6)
        :Radii(0, 0, 16, 16)
        :Color(Mantle.color.text)
    :Draw()

    draw.SimpleText(text, 'Fated.40', 0, y - 2, Mantle.color.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
end

function Mantle.func.draw_ent_text(ent, text, posY)
    local distSqr = EyePos():DistToSqr(ent:GetPos())
    local maxDist = 380
    if distSqr > maxDist * maxDist then return end

    local dist = math.sqrt(distSqr)
    local minDist = 20

    local idx = ent:EntIndex()
    local prev = Mantle.func.ents_scales[idx] or 0

    local normalized = math.Clamp((maxDist - dist) / math.max(1, (maxDist - minDist)), 0, 1)

    local appearThreshold = 0.8
    local disappearThreshold = 0.01

    local target
    if normalized <= disappearThreshold then
        target = 0
    elseif normalized >= appearThreshold then
        target = 1
    else
        target = (normalized - disappearThreshold) / (appearThreshold - disappearThreshold)
    end

    local dt = FrameTime() or 0.016
    local appearSpeed = 18
    local disappearSpeed = 12
    local speed = (target > prev) and appearSpeed or disappearSpeed

    local cur = Mantle.func.approachExp(prev, target, speed, dt)
    if math.abs(cur - target) < 0.0005 then cur = target end
    Mantle.func.ents_scales[idx] = cur

    local eased = Mantle.func.easeInOutCubic(cur)
    local alpha = eased
    local baseScale = 0.13
    local camScale = baseScale * math.max(1e-4, eased)

    if eased < 0.01 then
        surface.SetAlphaMultiplier(1)
        return
    end

    local _, max = ent:GetRotatedAABB(ent:OBBMins(), ent:OBBMaxs())
    local rot = (ent:GetPos() - EyePos()):Angle().yaw - 90
    local bob = math.sin(CurTime() + idx) / 3 + 0.5
    local center = ent:LocalToWorld(ent:OBBCenter())

    surface.SetAlphaMultiplier(alpha)
    cam.Start3D2D(center + Vector(0, 0, math.abs(max.z / 2) + 12 + bob), Angle(0, rot, 90), camScale)
        drawEntText(text, posY)
    cam.End3D2D()
    surface.SetAlphaMultiplier(1)
end
