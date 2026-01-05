local PANEL = {}

function PANEL:Init()
    self.tabs = {}
    self.active_index = 1

    self.content = vgui.Create('Panel', self)
    self.content:Dock(FILL)

    self.header = vgui.Create('Panel', self.content)
    self.header:Dock(TOP)
    self.header:DockMargin(0, 0, 0, 8)
    self.header:SetTall(64)
    self.header.Paint = function(s, w, h)
        local cfg = self.tabs[self.active_index].cfg

        RNDX().Rect(0, 0, w, h)
            :Rad(8)
            :Color(Mantle.color.tab_top_panel)
        :Draw()

        local iconSize = cfg.icon and 32 or 0
        local iconGap = cfg.icon and 12 or 0
        local startX = 16

        if cfg.icon then
            RNDX().Rect(startX, (h - iconSize) * 0.5, iconSize, iconSize)
                :Material(cfg.icon)
                :Color(Mantle.color.tab_active)
            :Draw()

            startX = startX + iconSize + iconGap
        end

        draw.SimpleText(cfg.title, 'Fated.Medium', startX, h * 0.5 - 1, Mantle.color.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        draw.SimpleText(cfg.description, 'Fated.Regular', startX, h * 0.5 + 1, Mantle.color.text_muted)
    end
    self.header:SetVisible(false)

    self.tabBar = vgui.Create('Panel', self)
    self.tabBar:SetSize(0, 48)
    self.tabBar.Paint = function(s, w, h)
        RNDX().Rect(0, 0, w, h)
            :Rad(32)
            :Blur(1, 10)
        :Draw()

        RNDX().Rect(0, 0, w, h)
            :Rad(32)
            :Color(Mantle.color.tab_panel)
        :Draw()

        RNDX().Rect(0, 0, w, h)
            :Rad(32)
            :Color(Mantle.color.outline)
            :Outline(1)
        :Draw()
    end

    self._tab_gap = 4
    self._tab_side_padding = 16
    self._accum_width = 0
end

function PANEL:AddTab(cfg, panel, oldIcon)
    if isstring(cfg) then
        local cfgTitle = cfg
        cfg = {
            title = cfgTitle
        }

        if oldIcon then
            cfg.icon = oldIcon
        end
    end

    panel:SetParent(self.content)
    panel:Dock(FILL)
    panel:SetVisible(#self.tabs == 0)

    self.tabs[#self.tabs + 1] = {
        cfg = cfg,
        panel = panel
    }

    surface.SetFont('Fated.18')
    local textWide = surface.GetTextSize(cfg.title)

    local hasIcon = cfg.icon ~= nil
    local iconSize = hasIcon and 16 or 0
    local iconGap = hasIcon and 6 or 0

    local btnW = textWide + iconSize + iconGap + 12

    local tabBtn = vgui.Create('Button', self.tabBar)
    tabBtn:Dock(LEFT)
    tabBtn:SetWide(btnW)
    tabBtn:SetTall(self.tabBar:GetTall() - 8)
    tabBtn:SetText('')

    local idx = #self.tabs
    local leftMargin = (idx == 1) and self._tab_side_padding or self._tab_gap
    tabBtn:DockMargin(leftMargin, 4, 0, 4)

    tabBtn.DoClick = function()
        self.active_index = idx

        for i, t in ipairs(self.tabs) do
            if IsValid(t.panel) then
                t.panel:SetVisible(i == idx)
            end
        end

        local activeCfg = self.tabs[self.active_index].cfg
        if activeCfg.description then
            self.header:SetVisible(true)
        else
            self.header:SetVisible(false)
        end

        self.header:InvalidateLayout()
    end

    tabBtn.Paint = function(s, w, h)
        local active = (self.active_index == idx)
        local col = active and Mantle.color.tab_active or Mantle.color.tab_text

        local contentW = textWide + iconSize + iconGap
        local startX = (w - contentW) * 0.5

        if hasIcon then
            RNDX().Rect(startX, (h - iconSize) * 0.5, iconSize, iconSize)
                :Material(cfg.icon)
                :Color(col)
            :Draw()

            startX = startX + iconSize + iconGap
        end

        draw.SimpleText(
            cfg.title,
            'Fated.Regular',
            startX,
            h * 0.5,
            col,
            TEXT_ALIGN_LEFT,
            TEXT_ALIGN_CENTER
        )
    end

    self._accum_width = self._accum_width + btnW + leftMargin
    self.tabBar:SetWide(self._accum_width + self._tab_side_padding)

    if #self.tabs == 1 then
        self.active_index = 1
        if cfg.description then
            self.header:SetVisible(true)
        else
            self.header:SetVisible(false)
        end
    end
end

function PANEL:PerformLayout(w, h)
    self.tabBar:SetPos(w * 0.5 - self.tabBar:GetWide() * 0.5, h - self.tabBar:GetTall() - 12)
end

function PANEL:SetTabStyle()
end

vgui.Register('MantleTabs', PANEL, 'EditablePanel')
