local PANEL = {}

function PANEL:Init()
    self.tabs = {}
    self.active_id = 1

    self.panel_tabs = vgui.Create('Panel', self)
    self.panel_tabs.Paint = nil
    
    self.content = vgui.Create('Panel', self)
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

function PANEL:Rebuild()
    self.panel_tabs:Clear()

    for id, tab in ipairs(self.tabs) do
        local btnTab = vgui.Create('Button', self.panel_tabs)
        btnTab:SetTall(30)
        btnTab:Dock(TOP)
        btnTab:DockMargin(0, 0, 0, 6)
        btnTab:SetText('')
        btnTab.DoClick = function()
            self.tabs[self.active_id].pan:SetVisible(false)
            tab.pan:SetVisible(true)
            self.active_id = id

            Mantle.func.sound()
        end

        local color_draw = Color(255, 255, 255)

        btnTab.Paint = function(s, w, h)
            local color_target = Color(255, 255, 255)

            if self.active_id == id then
                color_target = Color(Mantle.color.theme.r, Mantle.color.theme.g, Mantle.color.theme.b)
            end

            local r = Lerp(FrameTime() * 10, color_draw.r, color_target.r)
            local g = Lerp(FrameTime() * 10, color_draw.g, color_target.g)
            local b = Lerp(FrameTime() * 10, color_draw.b, color_target.b)
            color_draw = Color(r, g, b)

            draw.SimpleText(tab.name, 'Fated.18', 41, h * 0.5 + 1, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(tab.name, 'Fated.18', 40, h * 0.5, color_draw, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

            if tab.icon then
                surface.SetDrawColor(color_draw)
                surface.SetMaterial(tab.icon)
                surface.DrawTexturedRect(0, 0, 30, 30)
            else
                draw.RoundedBox(6, 0, 0, 30, 30, color_draw)
            end
        end
    end
end

function PANEL:PerformLayout(w, h)
    self.panel_tabs:Dock(LEFT)
    self.panel_tabs:SetWide(180)

    self.content:Dock(FILL)
end

vgui.Register('MantleTabs', PANEL, 'Panel')
