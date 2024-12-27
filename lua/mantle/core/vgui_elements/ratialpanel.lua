local math_cos = math.cos
local math_sin = math.sin
local math_rad = math.rad
local math_floor = math.floor
local math_deg = math.deg
local math_atan2 = math.atan2
local math_sqrt = math.sqrt

local function DrawArc(cx, cy, radius, thickness, startAngle, endAngle, color)
    local arc = {}
    local innerRadius = radius - thickness

    for i = startAngle, endAngle, 1 do
        local rad = math_rad(i)
        table.insert(arc, {
            x = cx + math_cos(rad) * radius,
            y = cy + math_sin(rad) * radius,
        })
    end

    for i = endAngle, startAngle, -1 do
        local rad = math_rad(i)
        table.insert(arc, {
            x = cx + math_cos(rad) * innerRadius,
            y = cy + math_sin(rad) * innerRadius,
        })
    end

    surface.SetDrawColor(color)
    draw.NoTexture()
    surface.DrawPoly(arc)
end

local segmentColors = {}

function Mantle.ui.ratial_panel(items_config, disable_start_anim_bool, disable_background_bool)
    if IsValid(Mantle.ui.menu_ratial_panel) then
        Mantle.ui.menu_ratial_panel:Remove()
    end

    Mantle.ui.menu_ratial_panel = vgui.Create('DPanel')
    Mantle.ui.menu_ratial_panel:SetSize(Mantle.func.sw, Mantle.func.sh)
    Mantle.ui.menu_ratial_panel:Center()
    Mantle.ui.menu_ratial_panel:MakePopup()
    
    if !disable_start_anim_bool then
        Mantle.ui.menu_ratial_panel:SetAlpha(0)
        Mantle.ui.menu_ratial_panel:AlphaTo(255, 0.1, 0)
    end

    for i = 1, #items_config do
        segmentColors[i] = Mantle.color.header
    end

    local centerX, centerY = Mantle.func.sw * 0.5, Mantle.func.sh * 0.5
    local radius = 200
    local thickness = 90
    local selectedSegment = nil
    local hoveredText = nil

    Mantle.ui.menu_ratial_panel.Paint = function(_, w, h)
        if !disable_background_bool then
            draw.RoundedBox(0, 0, 0, w, h, Mantle.color.background_alpha)
        end

        local angleStep = 360 / #items_config

        for i, btnConfig in ipairs(items_config) do
            local startAngle = (i - 1) * angleStep
            local endAngle = i * angleStep
            local isHovered = (selectedSegment == i)
            local targetColor = isHovered and Mantle.color.theme or Mantle.color.header
            local currentColor = segmentColors[i]
            
            segmentColors[i] = Color(
                Lerp(FrameTime() * 10, currentColor.r, targetColor.r),
                Lerp(FrameTime() * 10, currentColor.g, targetColor.g),
                Lerp(FrameTime() * 10, currentColor.b, targetColor.b),
                Lerp(FrameTime() * 10, currentColor.a, targetColor.a)
            )

            DrawArc(centerX, centerY, radius, thickness, startAngle, endAngle, segmentColors[i])

            local midAngle = math_rad((startAngle + endAngle) / 2)
            local buttonX = centerX + math_cos(midAngle) * (radius - thickness / 1.9)
            local buttonY = centerY + math_sin(midAngle) * (radius - thickness / 1.9)

            draw.SimpleText(btnConfig.name, 'Fated.20', buttonX, buttonY, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            if isHovered then
                hoveredText = btnConfig.name
            end
        end

        if hoveredText then
            draw.SimpleText(hoveredText, 'Fated.22', centerX + 1, centerY + 1, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(hoveredText, 'Fated.22', centerX, centerY, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    function Mantle.ui.menu_ratial_panel:Think()
        local mouseX, mouseY = Mantle.ui.menu_ratial_panel:CursorPos()
        local dx, dy = mouseX - centerX, mouseY - centerY
        local angle = math_deg(math_atan2(dy, dx))

        if angle < 0 then
            angle = angle + 360
        end

        local newSegment = math_floor(angle / (360 / #items_config)) + 1

        if newSegment != selectedSegment then
            Mantle.func.sound('mantle/ratio_btn.ogg')
        end

        selectedSegment = newSegment
    end

    local function ClosePanel(end_anim_off_bool)
        if !end_anim_off_bool then
            Mantle.ui.menu_ratial_panel:AlphaTo(0, 0.07, 0.1, function(_, self)
                self:Remove()
            end)
        else
            Mantle.ui.menu_ratial_panel:Remove()
        end
    end

    function Mantle.ui.menu_ratial_panel:OnMousePressed(mouse_code)
        local mouseX, mouseY = Mantle.ui.menu_ratial_panel:CursorPos()
        local dx, dy = mouseX - centerX, mouseY - centerY
        local distance = math_sqrt(dx * dx + dy * dy)

        if mouse_code == MOUSE_LEFT then
            if distance <= radius and selectedSegment then
                local btnConfig = items_config[selectedSegment]

                if btnConfig and btnConfig.func then
                    btnConfig.func()
                end
                
                ClosePanel(btnConfig.off_anim)
            elseif distance > radius then
                ClosePanel()
            end
        elseif mouse_code == MOUSE_RIGHT then
            ClosePanel()
        end
    end

    return Mantle.ui.menu_ratial_panel
end
