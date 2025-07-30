local PANEL = {}

local math_rad = math.rad
local math_cos = math.cos
local math_sin = math.sin
local math_atan2 = math.atan2
local math_sqrt = math.sqrt
local math_min = math.min

function PANEL:Init(options)
    options = options or {}
    self.options = {}
    self.menuStack = {}
    self.currentMenu = nil

    local baseRadius = options.radius or 280
    local baseInnerRadius = options.inner_radius or 96
    
    local minWidth = 1366
    local minHeight = 768
    
    -- Если разрешение меньше минимального, используем базовый размер
    -- Если больше - масштабируем пропорционально
    local scale = 1
    if Mantle.func.sw > minWidth and Mantle.func.sh > minHeight then
        scale = math_min(
            math_min(Mantle.func.sw / 1920, Mantle.func.sh / 1080),
            1.5 -- Максимальный масштаб 150%
        )
    end

    local paddingScale = 1
    if Mantle.func.sw <= 1280 then
        paddingScale = 1.3
    end
    
    self.radius = Mantle.func.w(baseRadius) * scale
    self.innerRadius = Mantle.func.w(baseInnerRadius) * scale
    self.paddingScale = paddingScale
    
    self.selectedOption = nil
    self.hoverOption = nil
    self.hoverAnim = 0
    self.centerText = 'Меню'
    self.centerDesc = 'Выберите опцию'
    self.font = 'Fated.20'
    self.descFont = 'Fated.16'
    self.titleFont = 'Fated.28'
    self.blurStart = SysTime()
    self.fadeInTime = 0.2
    self.currentAlpha = 0
    self.scaleAnim = 0
    self.scale = scale

    -- Кастомизация
    self.disable_background = options.disable_background or false
    self.hover_sound = options.hover_sound or 'mantle/ratio_btn.ogg'
    self.scale_animation = options.scale_animation != false
    
    self:SetSize(Mantle.func.sw, Mantle.func.sh)
    self:SetPos(0, 0)
    self:MakePopup()
    self:SetKeyboardInputEnabled(false)
    self:SetDrawOnTop(true)
    self:SetMouseInputEnabled(true)
    
    self._mouseWasDown = false
    
    self.Think = function()
        if self.currentAlpha < 255 then
            self.currentAlpha = math.Clamp(255 * ((SysTime() - self.blurStart) / self.fadeInTime), 0, 255)
            if self.scale_animation then
                self.scaleAnim = math.Clamp(((SysTime() - self.blurStart) / self.fadeInTime), 0, 1)
                self.scaleAnim = 0.8 + (self.scaleAnim * 0.2)
            else
                self.scaleAnim = 1
            end
        end
    
        local mouseDown = input.IsMouseDown(MOUSE_LEFT)
        if mouseDown and not self._mouseWasDown then
            local mouseX, mouseY = self:CursorPos()
            local centerX, centerY = Mantle.func.sw / 2, Mantle.func.sh / 2
            local dist = math_sqrt((mouseX - centerX)^2 + (mouseY - centerY)^2)
            
            if dist > self.innerRadius and dist < self.radius then
                local angle = math_atan2(mouseY - centerY, mouseX - centerX)
                if angle < 0 then angle = angle + math_rad(360) end
                
                local optionCount = #self:GetCurrentOptions()
                if optionCount > 0 then
                    local sectorSize = math_rad(360) / optionCount
                    local selectedIndex = math.floor(angle / sectorSize) + 1
                    
                    if selectedIndex <= optionCount then
                        self:SelectOption(selectedIndex)
                        Mantle.func.sound()
                    end
                end
            elseif dist <= self.innerRadius then
                if #self.menuStack > 0 then
                    self:GoBack()
                    Mantle.func.sound()
                else
                    self:Remove()
                end
            elseif dist >= self.radius then
                self:Remove()
            end
        end
        
        local mouseX, mouseY = self:CursorPos()
        local centerX, centerY = Mantle.func.sw / 2, Mantle.func.sh / 2
        local dist = math_sqrt((mouseX - centerX)^2 + (mouseY - centerY)^2)
        local hovered = nil
        
        if dist > self.innerRadius and dist < self.radius then
            local angle = math_atan2(mouseY - centerY, mouseX - centerX)
            if angle < 0 then angle = angle + math_rad(360) end
            
            local optionCount = #self:GetCurrentOptions()
            if optionCount > 0 then
                local sectorSize = math_rad(360) / optionCount
                hovered = math.floor(angle / sectorSize) + 1
                if hovered > optionCount then hovered = nil end
            end
        end
        
        if self.hoverOption != hovered and hovered and self.hover_sound then
            surface.PlaySound(self.hover_sound)
        end
        
        self.hoverOption = hovered
        self.hoverAnim = math.Clamp(self.hoverAnim + (self.hoverOption and 4 or -8) * FrameTime(), 0, 1)
        self._mouseWasDown = mouseDown
    end
end

function PANEL:OnMousePressed(keyCode)
    local mouseX, mouseY = self:CursorPos()
    local centerX, centerY = Mantle.func.sw / 2, Mantle.func.sh / 2
    local dist = math_sqrt((mouseX - centerX)^2 + (mouseY - centerY)^2)
    
    if dist <= self.radius then
        return self:MouseCapture(true)
    end
    
    self:Remove()
    return true
end

function PANEL:OnMouseReleased(keyCode)
    self:MouseCapture(false)
end

function PANEL:Paint(w, h)
    local centerX, centerY = Mantle.func.sw / 2, Mantle.func.sh / 2
    local alpha = self.currentAlpha/255

    if not self.disable_background then
        local bgCol = Color(0, 0, 0, 100 * alpha)
        RNDX.Draw(0, 0, 0, w, h, bgCol, RNDX.SHAPE_RECT)
    end
    
    local outerSize = self.radius * 2 + Mantle.func.w(20) * self.scale
    local currentRadius = self.radius * self.scaleAnim
    local currentInnerRadius = self.innerRadius * self.scaleAnim
    
    BShadows.BeginShadow()
    RNDX.Draw(outerSize / 2 * self.scaleAnim, centerX - (outerSize / 2 * self.scaleAnim), centerY - (outerSize / 2 * self.scaleAnim), 
        outerSize * self.scaleAnim, outerSize * self.scaleAnim, ColorAlpha(Mantle.color.background, 220 * alpha), RNDX.SHAPE_CIRCLE)
    BShadows.EndShadow(1, 2, 2, 255 * alpha, 0, 0)
    
    BShadows.BeginShadow()
    RNDX.Draw(currentRadius, centerX - currentRadius, centerY - currentRadius, 
        currentRadius * 2, currentRadius * 2, ColorAlpha(Mantle.color.background, 240 * alpha), RNDX.SHAPE_CIRCLE)
    BShadows.EndShadow(1, 2, 2, 255 * alpha, 0, 0)
    
    BShadows.BeginShadow()
    RNDX.Draw(currentInnerRadius, centerX - currentInnerRadius, centerY - currentInnerRadius, 
        currentInnerRadius * 2, currentInnerRadius * 2, ColorAlpha(Mantle.color.background_panelpopup, self.currentAlpha), RNDX.SHAPE_CIRCLE)
    BShadows.EndShadow(1, 1, 1, (Mantle.ui.convar.theme == 'light' and 150 or 200) * alpha, 0, 0)
    
    local textColor = Mantle.ui.convar.theme == 'light' and Color(30, 30, 30) or Color(255, 255, 255)
    draw.SimpleText(self.centerText, self.titleFont, centerX, centerY - Mantle.func.h(13) * self.scale, ColorAlpha(textColor, self.currentAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(self.centerDesc, self.descFont, centerX, centerY + Mantle.func.h(13) * self.scale, ColorAlpha(textColor, 180 * alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    local optionCount = #self:GetCurrentOptions()
    if optionCount > 0 then
        local sectorSize = math_rad(360) / optionCount
        
        for i, option in ipairs(self:GetCurrentOptions()) do
            local startAngle = (i - 1) * sectorSize
            local endAngle = i * sectorSize
            local midAngle = startAngle + sectorSize / 2
            local isHovered = (self.hoverOption == i)
            
            local textX = centerX + (currentInnerRadius + (currentRadius - currentInnerRadius) / 2) * math_cos(midAngle)
            local textY = centerY + (currentInnerRadius + (currentRadius - currentInnerRadius) / 2) * math_sin(midAngle)
            
            local baseColor = Mantle.ui.convar.theme == 'light' and Color(30, 30, 30) or Color(255, 255, 255)
            local textColor = ColorAlpha(baseColor, (isHovered and 255 or 200) * alpha)
            
            if option.icon and option.icon != false and option.icon != nil then
                local iconMat = Material(option.icon)
                local iconSize = Mantle.func.w(32) * self.scale * self.scaleAnim
                local iconColor = ColorAlpha(color_white, self.currentAlpha)
                RNDX.DrawMaterial(0, textX - iconSize/2, textY - iconSize - Mantle.func.h(8) * self.scale * self.paddingScale, 
                    iconSize, iconSize, iconColor, iconMat)
                
                draw.SimpleText(option.text, self.font, textX, textY + Mantle.func.h(4) * self.scale * self.paddingScale, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                
                if option.desc and isHovered then
                    draw.SimpleText(option.desc, self.descFont, textX, textY + Mantle.func.h(20) * self.scale * self.paddingScale, 
                        ColorAlpha(baseColor, 180 * self.hoverAnim * alpha),
                        TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            else
                draw.SimpleText(option.text, self.font, textX, textY - Mantle.func.h(8) * self.scale * self.paddingScale, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                
                if option.desc and isHovered then
                    draw.SimpleText(option.desc, self.descFont, textX, textY + Mantle.func.h(8) * self.scale * self.paddingScale, 
                        ColorAlpha(baseColor, 180 * self.hoverAnim * alpha),
                        TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end
        end
    end
    
    if optionCount > 0 then
        local lineHighlightColor = ColorAlpha(Mantle.color.theme, (Mantle.ui.convar.theme == 'light' and 100 or 60) * alpha)
        self:DrawCircleOutline(centerX, centerY, currentRadius, lineHighlightColor, 1)
        self:DrawCircleOutline(centerX, centerY, currentInnerRadius, lineHighlightColor, 1)
    end
end

function PANEL:DrawCircleOutline(cx, cy, radius, color, thickness)
    local segments = 64
    local points = {}
    
    for i = 0, segments do
        local angle = math_rad((i / segments) * 360)
        table.insert(points, {
            x = cx + radius * math_cos(angle),
            y = cy + radius * math_sin(angle)
        })
    end
    
    surface.SetDrawColor(color)
    
    for i = 1, #points - 1 do
        surface.DrawLine(points[i].x, points[i].y, points[i+1].x, points[i+1].y)
    end
    
    surface.DrawLine(points[#points].x, points[#points].y, points[1].x, points[1].y)
end

function PANEL:AddOption(text, func, icon, desc, submenu)
    table.insert(self.options, {
        text = text,
        func = func,
        icon = icon,
        desc = desc,
        submenu = submenu
    })
    return #self.options
end

function PANEL:SelectOption(index)
    local options = self:GetCurrentOptions()
    if options[index] then
        local option = options[index]
        
        if option.submenu then
            table.insert(self.menuStack, self.currentMenu)

            self.currentMenu = option.submenu
            self:UpdateCenterText()
        elseif option.func then
            option.func()
            self:Remove()
        end
    end
end

function PANEL:SetCenterText(title, desc)
    self.centerText = title or 'Меню'
    self.centerDesc = desc or 'Выберите опцию'
end

function PANEL:IsMouseOver()
    local mouseX, mouseY = self:CursorPos()
    local centerX, centerY = Mantle.func.sw / 2, Mantle.func.sh / 2
    return math_sqrt((mouseX - centerX)^2 + (mouseY - centerY)^2) <= self.radius
end

function PANEL:OnCursorMoved(x, y)
    if not self:IsMouseOver() then
        self.hoverOption = nil
    end
end

function PANEL:OnRemove()
    if Mantle.ui.menu_radial == self then
        Mantle.ui.menu_radial = nil
    end
end

vgui.Register('MantleRadialPanel', PANEL, 'DPanel')

function Mantle.ui.radial_menu(options)
    if IsValid(Mantle.ui.menu_radial) then
        Mantle.ui.menu_radial:Remove()
    end
    
    local m = vgui.Create('MantleRadialPanel')
    m:Init(options)
    Mantle.ui.menu_radial = m
    return m
end

function PANEL:GetCurrentOptions()
    if self.currentMenu then
        return self.currentMenu.options or {}
    end
    return self.options
end

function PANEL:GoBack()
    if #self.menuStack > 0 then
        self.currentMenu = table.remove(self.menuStack)
        self:UpdateCenterText()
    end
end

function PANEL:UpdateCenterText()
    if self.currentMenu then
        self.centerText = self.currentMenu.title or 'Меню'
        self.centerDesc = self.currentMenu.desc or 'Выберите опцию'
    else
        self.centerText = 'Меню'
        self.centerDesc = 'Выберите опцию'
    end
end

function PANEL:CreateSubMenu(title, desc)
    local submenu = {
        title = title,
        desc = desc,
        options = {}
    }

    function submenu:AddOption(text, func, icon, desc)
        table.insert(self.options, {
            text = text,
            func = func,
            icon = icon,
            desc = desc
        })
        return #self.options
    end

    return submenu
end

function PANEL:AddSubMenuOption(text, submenu, icon, desc)
    return self:AddOption(text, nil, icon, desc, submenu)
end
