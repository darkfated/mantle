local PANEL = {}

function PANEL:Init()
    self.title = nil
    self.placeholder = 'Введите текст'

    self:SetTall(26)
    self.action = function()
        // что-то
    end

    local font = 'Fated.18'

    self.textEntry = vgui.Create('DTextEntry', self)
    self.textEntry:Dock(FILL)
    self.textEntry:SetText('')
    self.textEntry.OnCloseFocus = function()
        self.action(self:GetValue())
    end
    self._text_offset = 0
    self.textEntry.Paint = nil
    self.textEntry.PaintOver = function(s, w, h)
        if Mantle.ui.convar.depth_ui then
            if !s._shadowLerp then
                s._shadowLerp = 5
            end
            local target = s:IsEditing() and 10 or 5
            s._shadowLerp = Lerp(FrameTime() * 10, s._shadowLerp, target)
            RNDX.DrawShadows(16, 0, 0, w, h, Mantle.color.window_shadow, s._shadowLerp, 20, RNDX.SHAPE_IOS)
        end
        RNDX.Draw(16, 0, 0, w, h, Mantle.color.focus_panel, RNDX.SHAPE_IOS)

        local value = self:GetValue()
        surface.SetFont(font)
        local padding = 6
        local available_w = w - padding * 2

        local caret = #value
        local before_caret = string.sub(value, 1, caret)
        local caret_x = surface.GetTextSize(before_caret)
        local text_w = surface.GetTextSize(value)

        local desired_offset = 0
        if caret_x > available_w then
            desired_offset = caret_x - available_w
        end
        if text_w - desired_offset < available_w then
            desired_offset = math.max(0, text_w - available_w)
        end

        self._text_offset = Lerp(FrameTime() * 15, self._text_offset or 0, desired_offset)

        local text = self.placeholder
        local col = Mantle.color.gray
        if value ~= '' then
            text = value
            col = Mantle.color.text
        end

        draw.SimpleText(text, font, padding - self._text_offset, h * 0.5, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
end

function PANEL:SetTitle(title)
    self.title = title
    self:SetTall(52)

    self.titlePanel = vgui.Create('DPanel', self)
    self.titlePanel:Dock(TOP)
    self.titlePanel:DockMargin(0, 0, 0, 6)
    self.titlePanel:SetTall(18)
    self.titlePanel.Paint = function(_, w, h)
        draw.SimpleText(self.title, 'Fated.18', 0, 0, Mantle.color.text)
    end
end

function PANEL:SetPlaceholder(placeholder)
    self.placeholder = placeholder
end

function PANEL:GetValue()
    return self.textEntry:GetText()
end

vgui.Register('MantleEntry', PANEL, 'EditablePanel')
