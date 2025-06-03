local PANEL = {}

function PANEL:Init()
    self.tabs = {}
    self.active_id = 1
    self.tab_height = 38
    self.animation_speed = 8
    self.tab_style = 'modern' -- modern или classic
    self.indicator_height = 2

    self.panel_tabs = vgui.Create('Panel', self)
    self.panel_tabs.Paint = nil
    
    self.content = vgui.Create('Panel', self)
    self.content.Paint = nil
end

function PANEL:SetTabStyle(style)
    self.tab_style = style
    self:Rebuild()
end

function PANEL:SetTabHeight(height)
    self.tab_height = height
    self:Rebuild()
end

function PANEL:SetIndicatorHeight(height)
    self.indicator_height = height
    self:Rebuild()
end

function PANEL:AddTab(name, pan, icon)
    local newId = #self.tabs + 1

    self.tabs[newId] = {
        name = name,
        pan = pan,
        icon = icon
    }

    self.tabs[newId].pan:SetParent(self.content)
    self.tabs[newId].pan:Dock(FILL)
    self.tabs[newId].pan:SetVisible(newId == 1 and true or false)

    self:Rebuild()
end

local color_btn_hovered = Color(255, 255, 255, 10)

function PANEL:Rebuild()
    self.panel_tabs:Clear()

    for id, tab in ipairs(self.tabs) do
        local btnTab = vgui.Create('Button', self.panel_tabs)
        
        if self.tab_style == 'modern' then
            btnTab:Dock(LEFT)
            btnTab:DockMargin(0, 0, 6, 0)
            btnTab:SetTall(34)
            btnTab:SetWide(140)
        else
            btnTab:Dock(TOP)
            btnTab:DockMargin(0, 0, 0, 6)
            btnTab:SetTall(34)
        end
        
        btnTab:SetText('')
        btnTab.DoClick = function()
            self.tabs[self.active_id].pan:SetVisible(false)
            tab.pan:SetVisible(true)
            self.active_id = id

            Mantle.func.sound()
        end

        local color_draw = Color(255, 255, 255)

        btnTab.Paint = function(s, w, h)
            if self.tab_style == 'modern' then
                -- Современный стиль с индикатором внизу
                if s:IsHovered() then
                    draw.RoundedBox(8, 0, 0, w, h, color_btn_hovered)
                end
                
                local isActive = self.active_id == id
                
                if isActive then
                    draw.RoundedBox(2, 0, h - self.indicator_height, w, self.indicator_height, Mantle.color.theme)
                end

                draw.SimpleText(
                    tab.name, 
                    'Fated.18', 
                    tab.icon and 34 or w * 0.5, 
                    h * 0.5, 
                    isActive and Mantle.color.theme or color_white, 
                    tab.icon and TEXT_ALIGN_LEFT or TEXT_ALIGN_CENTER, 
                    TEXT_ALIGN_CENTER
                )

                if tab.icon then
                    surface.SetDrawColor(isActive and Mantle.color.theme or color_white)
                    surface.SetMaterial(tab.icon)
                    surface.DrawTexturedRect(8, (h - 20) * 0.5, 20, 20)
                end
            else
                if s:IsHovered() then
                    draw.RoundedBox(8, 0, 0, w, h, color_btn_hovered)
                end

                local color_target = Color(255, 255, 255)

                if self.active_id == id then
                    color_target = Color(Mantle.color.theme.r, Mantle.color.theme.g, Mantle.color.theme.b)
                end

                local r = Lerp(FrameTime() * self.animation_speed, color_draw.r, color_target.r)
                local g = Lerp(FrameTime() * self.animation_speed, color_draw.g, color_target.g)
                local b = Lerp(FrameTime() * self.animation_speed, color_draw.b, color_target.b)
                color_draw = Color(r, g, b)

                draw.SimpleText(tab.name, 'Fated.20', 41, h * 0.5, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(tab.name, 'Fated.20', 40, h * 0.5 - 1, color_draw, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                if tab.icon then
                    surface.SetDrawColor(color_draw)
                    surface.SetMaterial(tab.icon)
                    surface.DrawTexturedRect(2, 2, 30, 30)
                else
                    draw.RoundedBox(6, 0, 0, 30, 30, color_draw)
                end
            end
        end
    end
end

function PANEL:PerformLayout(w, h)
    if self.tab_style == 'modern' then
        self.panel_tabs:Dock(TOP)
        self.panel_tabs:DockMargin(0, 0, 0, 4)
        self.panel_tabs:SetTall(self.tab_height)
    else
        self.panel_tabs:Dock(LEFT)
        self.panel_tabs:DockMargin(0, 0, 4, 0)
        self.panel_tabs:SetWide(190)
    end

    self.content:Dock(FILL)
end

vgui.Register('MantleTabs', PANEL, 'Panel')
