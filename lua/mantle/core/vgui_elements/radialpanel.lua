local math_cos = math.cos
local math_sin = math.sin
local math_rad = math.rad
local math_floor = math.floor
local math_deg = math.deg
local math_atan2 = math.atan2
local math_sqrt = math.sqrt
local math_pi = math.pi
local math_clamp = math.Clamp
local math_approach = math.Approach

local function DrawArc(cx, cy, radius, thickness, startAngle, endAngle, color, segments)
    segments = segments or math.max(20, math.floor((endAngle - startAngle) / 5))
    
    local arc = {}
    local innerRadius = radius - thickness
    local angleStep = (endAngle - startAngle) / segments

    for i = 0, segments do
        local angle = math_rad(startAngle + (i * angleStep))
        table.insert(arc, {
            x = cx + math_cos(angle) * radius,
            y = cy + math_sin(angle) * radius
        })
    end

    for i = segments, 0, -1 do
        local angle = math_rad(startAngle + (i * angleStep))
        table.insert(arc, {
            x = cx + math_cos(angle) * innerRadius,
            y = cy + math_sin(angle) * innerRadius
        })
    end
    
    surface.SetDrawColor(color)
    draw.NoTexture()
    surface.DrawPoly(arc)
end

local function DrawCircle(cx, cy, radius, color, segments)
    segments = segments or 32
    local circle = {}
    
    for i = 0, segments do
        local angle = math_rad((i / segments) * 360)
        table.insert(circle, {
            x = cx + math_cos(angle) * radius,
            y = cy + math_sin(angle) * radius
        })
    end
    
    surface.SetDrawColor(color)
    draw.NoTexture()
    surface.DrawPoly(circle)
end

function Mantle.ui.radial_panel(items_config, options)
    if IsValid(Mantle.ui.menu_ratial_panel) then
        Mantle.ui.menu_ratial_panel:Remove()
    end

    if IsValid(Mantle.ui.menu_radial_panel) then
        Mantle.ui.menu_radial_panel:Remove()
    end

    options = options or {}
    local disable_start_anim = options.disable_start_anim or false
    local disable_background = options.disable_background or false
    local menu_radius = options.radius or 180
    local inner_radius = options.inner_radius or 50
    local thickness = options.thickness or 80
    local animation_speed = options.animation_speed or 10
    local open_sound = options.open_sound or "mantle/btn_click.ogg"
    local hover_sound = options.hover_sound or "mantle/ratio_btn.ogg"
    local scale_animation = options.scale_animation or true

    local menu = vgui.Create('DPanel')
    Mantle.ui.menu_radial_panel = menu
    Mantle.ui.menu_ratial_panel = menu
    
    menu:SetSize(Mantle.func.sw, Mantle.func.sh)
    menu:Center()
    menu:MakePopup()
    menu:SetKeyboardInputEnabled(false)
    
    menu.segment_colors = {}
    menu.segment_scales = {}
    menu.selected_segment = nil
    menu.hover_segment = nil
    menu.hover_text = nil
    menu.center_scale = 0
    menu.scale_factor = 0
    menu.open_time = SysTime()
    menu.is_closing = false

    for i = 1, #items_config do
        menu.segment_colors[i] = Mantle.color.header
        menu.segment_scales[i] = 0
    end

    if not disable_start_anim then
        menu:SetAlpha(0)
        menu:AlphaTo(255, 0.2, 0)
        menu.scale_factor = 0.7
        
        if open_sound then
            surface.PlaySound(open_sound)
        end
    else
        menu.scale_factor = 1
    end

    local centerX, centerY = Mantle.func.sw * 0.5, Mantle.func.sh * 0.5

    menu.Paint = function(self, w, h)
        if !disable_background then
            RNDX.Draw(0, 0, 0, w, h, Mantle.color.background_alpha)
        end

        if scale_animation then
            if self.is_closing then
                self.scale_factor = math_approach(self.scale_factor, 0.7, FrameTime() * 4)
            else
                self.scale_factor = math_approach(self.scale_factor, 1, FrameTime() * 4)
            end
        else
            self.scale_factor = 1
        end

        local current_radius = menu_radius * self.scale_factor
        local current_thickness = thickness * self.scale_factor
        local current_inner = inner_radius * self.scale_factor
        
        local angleStep = 360 / #items_config
        
        menu.center_scale = Lerp(FrameTime() * 8, menu.center_scale, 1)
        
        BShadows.BeginShadow()
        DrawCircle(centerX, centerY, current_inner * menu.center_scale, Mantle.color.background, 32)
        BShadows.EndShadow(1, 2, 1, 255, 0, 0)
        
        DrawCircle(centerX, centerY, current_inner * menu.center_scale, Mantle.color.panel_alpha[2], 32)
        
        DrawCircle(centerX, centerY, current_inner * menu.center_scale - 2, Mantle.color.button, 32)
        
        if menu.hover_text then
            draw.SimpleText(menu.hover_text, 'Fated.18', centerX, centerY, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        for i, btnConfig in ipairs(items_config) do
            local startAngle = (i - 1) * angleStep
            local endAngle = i * angleStep
            local isHovered = (menu.hover_segment == i)
            
            menu.segment_scales[i] = Lerp(FrameTime() * 8, menu.segment_scales[i], isHovered and 1.05 or 1)
            
            local targetColor = isHovered and Mantle.color.theme or Mantle.color.header
            local currentColor = menu.segment_colors[i]
            
            menu.segment_colors[i] = Color(
                Lerp(FrameTime() * animation_speed, currentColor.r, targetColor.r),
                Lerp(FrameTime() * animation_speed, currentColor.g, targetColor.g),
                Lerp(FrameTime() * animation_speed, currentColor.b, targetColor.b),
                Lerp(FrameTime() * animation_speed, currentColor.a, targetColor.a)
            )
            
            local segRadius = current_radius * menu.segment_scales[i]
            
            DrawArc(centerX, centerY, segRadius, current_thickness, startAngle, endAngle, menu.segment_colors[i])
            
            local gradientColor = Color(0, 0, 0, 50)
            DrawArc(centerX, centerY, segRadius, current_thickness, startAngle, endAngle, gradientColor)
            
            local midAngle = math_rad((startAngle + endAngle) / 2)
            local textDistance = current_inner + current_thickness / 2
            local buttonX = centerX + math_cos(midAngle) * textDistance
            local buttonY = centerY + math_sin(midAngle) * textDistance
            
            draw.SimpleText(btnConfig.name, 'Fated.16', buttonX, buttonY, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            
            if btnConfig.icon then
                local iconSize = 24 * menu.segment_scales[i]
                local iconX = centerX + math_cos(midAngle) * (textDistance - 20)
                local iconY = centerY + math_sin(midAngle) * (textDistance - 20)
                
                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetMaterial(btnConfig.icon)
                surface.DrawTexturedRect(iconX - iconSize/2, iconY - iconSize/2, iconSize, iconSize)
            end
            
            if isHovered then
                menu.hover_text = btnConfig.name
            end
        end
    end

    menu.Think = function(self)
        local mouseX, mouseY = self:CursorPos()
        local dx, dy = mouseX - centerX, mouseY - centerY
        local distance = math_sqrt(dx * dx + dy * dy)
        
        if distance >= inner_radius and distance <= menu_radius then
            local angle = math_deg(math_atan2(dy, dx))
            
            if angle < 0 then
                angle = angle + 360
            end
            
            local newSegment = math_floor(angle / (360 / #items_config)) + 1
            
            if newSegment != menu.hover_segment then
                menu.hover_segment = newSegment
                
                if hover_sound then
                    surface.PlaySound(hover_sound)
                end
            end
        else
            menu.hover_segment = nil
            menu.hover_text = nil
        end
    end

    local function ClosePanel(skip_animation)
        if menu.is_closing then return end
        
        menu.is_closing = true
        
        if skip_animation then
            menu:Remove()
        else
            menu.scale_factor = 1
            menu:AlphaTo(0, 0.2, 0, function()
                menu:Remove()
            end)
        end
    end

    menu.OnMousePressed = function(self, mouse_code)
        local mouseX, mouseY = self:CursorPos()
        local dx, dy = mouseX - centerX, mouseY - centerY
        local distance = math_sqrt(dx * dx + dy * dy)
        
        if mouse_code == MOUSE_LEFT then
            if distance <= menu_radius and menu.hover_segment then
                local btnConfig = items_config[menu.hover_segment]
                
                if btnConfig and btnConfig.func then
                    btnConfig.func()
                end
                
                ClosePanel(btnConfig.off_anim)
            elseif distance > menu_radius then
                ClosePanel()
            end
        elseif mouse_code == MOUSE_RIGHT then
            ClosePanel()
        end
    end

    menu.OnKeyCodePressed = function(self, key_code)
        if key_code == KEY_ESCAPE then
            ClosePanel()
            return true
        end
    end

    return menu
end
