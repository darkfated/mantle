function Mantle.func.approachExp(current, target, speed, dt)
    local t = 1 - math.exp(-speed * dt)
    return current + (target - current) * t
end

function Mantle.func.easeOutCubic(t)
    return 1 - (1 - t) * (1 - t) * (1 - t)
end

function Mantle.func.easeInOutCubic(t)
    if t < 0.5 then
        return 4 * t * t * t
    else
        return 1 - math.pow(-2 * t + 2, 3) / 2
    end
end

function Mantle.func.LerpColor(speed, from, to, dt)
    local t = 1 - math.exp(-speed * (dt or FrameTime()))

    return Color(
        from.r + (to.r - from.r) * t,
        from.g + (to.g - from.g) * t,
        from.b + (to.b - from.b) * t,
        from.a + (to.a - from.a) * t
    )
end

function Mantle.func.animate_appearance(panel, target_w, target_h, duration, alpha_dur, callback, scale_factor)
    if not IsValid(panel) then return end
    duration = (duration and duration > 0) and duration or 0.18
    alpha_dur = (alpha_dur and alpha_dur > 0) and alpha_dur or duration

    local targetX, targetY = panel:GetPos()

    local initialScale = scale_factor or 0.8
    local initialW = target_w * initialScale
    local initialH = target_h * initialScale
    local initialX = targetX + (target_w - initialW) / 2
    local initialY = targetY + (target_h - initialH) / 2

    panel:SetSize(initialW, initialH)
    panel:SetPos(initialX, initialY)
    panel:SetAlpha(0)

    local curW, curH = initialW, initialH
    local curX, curY = initialX, initialY
    local curA = 0

    local eps = 0.5
    local alpha_eps = 1

    local speedSize = 3 / math.max(0.0001, duration)
    local speedAlpha = 3 / math.max(0.0001, alpha_dur)

    local state = panel.__mantleAppearance

    if !state then
        state = { think = panel.Think }
        panel.__mantleAppearance = state
    end

    local run = (state.run or 0) + 1
    state.run = run

    panel.Think = function(s)
        if state.run != run or !IsValid(s) then return end
        if state.think then state.think(s) end
        if !IsValid(s) then return end

        local dt = FrameTime()

        curW = Mantle.func.approachExp(curW, target_w, speedSize, dt)
        curH = Mantle.func.approachExp(curH, target_h, speedSize, dt)
        curX = Mantle.func.approachExp(curX, targetX, speedSize, dt)
        curY = Mantle.func.approachExp(curY, targetY, speedSize, dt)
        curA = Mantle.func.approachExp(curA, 255, speedAlpha, dt)

        s:SetSize(curW, curH)
        s:SetPos(curX, curY)
        s:SetAlpha(math.floor(curA + 0.5))

        local doneSize = math.abs(curW - target_w) <= eps and math.abs(curH - target_h) <= eps
        local donePos = math.abs(curX - targetX) <= eps and math.abs(curY - targetY) <= eps
        local doneAlpha = math.abs(curA - 255) <= alpha_eps

        if doneSize and donePos and doneAlpha then
            s:SetSize(target_w, target_h)
            s:SetPos(targetX, targetY)
            s:SetAlpha(255)
            s.Think = state.think
            s.__mantleAppearance = nil
            if callback then callback(s) end
        end
    end
end
