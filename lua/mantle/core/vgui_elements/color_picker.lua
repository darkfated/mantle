local colorTarget = Color(255, 255, 255, 200)

function Mantle.ui.color_picker(callback, defaultColor)
    if IsValid(Mantle.ui.menu_color_picker) then
        Mantle.ui.menu_color_picker:Remove()
    end

    local selectedColor = defaultColor or Color(255, 255, 255)
    local hue = 0
    local saturation = 1
    local value = 1
    local rgbEntries = {}

    if defaultColor then
        local r, g, b = defaultColor.r / 255, defaultColor.g / 255, defaultColor.b / 255
        local h, s, v = ColorToHSV(Color(r * 255, g * 255, b * 255))
        hue = h
        saturation = s
        value = v
    end

    local frame = vgui.Create('MantleFrame')
    Mantle.ui.menu_color_picker = frame
    frame:SetSize(320, 400)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle('')
    frame:SetCenterTitle(Mantle.lang.get('mantle', 'color_title'))
    frame:ShowAnimation()
    frame:DockPadding(12, 36, 12, 12)

    local preview = vgui.Create('Panel', frame)
    preview:Dock(TOP)
    preview:SetTall(40)
    preview:DockMargin(0, 0, 0, 8)
    preview.Paint = function(_, w, h)
        RNDX.Rect(0, 0, w, h)
            :Rad(16)
            :Color(selectedColor)
        :Draw()
    end

    local colorField = vgui.Create('Panel', frame)
    colorField:Dock(TOP)
    colorField:SetTall(190)
    colorField:DockMargin(0, 0, 0, 8)

    local colorCursor = { x = 0, y = 0 }
    local isDraggingColor = false

    colorField.OnMousePressed = function(self, keyCode)
        if keyCode == MOUSE_LEFT then
            isDraggingColor = true
            self:OnCursorMoved(self:CursorPos())
            Mantle.func.sound()
        end
    end

    colorField.OnMouseReleased = function(self, keyCode)
        if keyCode == MOUSE_LEFT then
            isDraggingColor = false
        end
    end

    colorField.OnCursorMoved = function(self, x, y)
        if isDraggingColor then
            local w, h = self:GetSize()
            x = math.Clamp(x, 0, w)
            y = math.Clamp(y, 0, h)

            colorCursor.x = x
            colorCursor.y = y

            saturation = x / w
            value = 1 - (y / h)

            selectedColor = HSVToColor(hue, saturation, value)

            for _, ch in ipairs({ 'R', 'G', 'B' }) do
                if IsValid(rgbEntries[ch]) then
                    rgbEntries[ch]:SetValue(tostring(ch == 'R' and selectedColor.r or ch == 'G' and selectedColor.g or selectedColor.b))
                end
            end
        end
    end

    colorField.Paint = function(self, w, h)
        RNDX.Rect(0, 0, w, h)
            :Rad(16)
            :Color(Mantle.color.window_shadow)
            :Shadow(4, 2)
        :Draw()

        local segments = 60
        local segmentSize = w / segments

        for x = 0, segments do
            for y = 0, segments do
                local s = x / segments
                local v = 1 - (y / segments)
                local segX = x * segmentSize
                local segY = y * segmentSize

                surface.SetDrawColor(HSVToColor(hue, s, v))
                surface.DrawRect(segX, segY, segmentSize + 1, segmentSize + 1)
            end
        end

        RNDX.Rect(0, 0, w, h)
            :Rad(16)
            :Color(Mantle.color.window_shadow)
            :Outline(1)
        :Draw()

        RNDX.Circle(colorCursor.x, colorCursor.y, 6)
            :Color(Mantle.color.window_shadow)
            :Shadow(2, 1)
        :Draw()

        RNDX.Circle(colorCursor.x, colorCursor.y, 6)
            :Outline(2)
            :Color(colorTarget)
        :Draw()
    end

    local hueSlider = vgui.Create('Panel', frame)
    hueSlider:Dock(TOP)
    hueSlider:SetTall(22)
    hueSlider:DockMargin(0, 0, 0, 8)

    local huePos = 0
    local isDraggingHue = false

    hueSlider.OnMousePressed = function(self, keyCode)
        if keyCode == MOUSE_LEFT then
            isDraggingHue = true
            self:OnCursorMoved(self:CursorPos())
            Mantle.func.sound()
        end
    end

    hueSlider.OnMouseReleased = function(self, keyCode)
        if keyCode == MOUSE_LEFT then
            isDraggingHue = false
        end
    end

    hueSlider.OnCursorMoved = function(self, x, y)
        if isDraggingHue then
            local w = self:GetWide()
            x = math.Clamp(x, 0, w)

            huePos = x
            hue = (x / w) * 360

            selectedColor = HSVToColor(hue, saturation, value)

            for _, ch in ipairs({ 'R', 'G', 'B' }) do
                if IsValid(rgbEntries[ch]) then
                    rgbEntries[ch]:SetValue(tostring(ch == 'R' and selectedColor.r or ch == 'G' and selectedColor.g or selectedColor.b))
                end
            end
        end
    end

    hueSlider.Paint = function(self, w, h)
        RNDX.Rect(0, 0, w, h)
            :Rad(12)
            :Color(Mantle.color.window_shadow)
            :Shadow(4, 2)
        :Draw()

        local segments = 60
        local segmentWidth = w / segments

        for i = 0, segments - 1 do
            local hueVal = (i / segments) * 360
            local x = i * segmentWidth

            surface.SetDrawColor(HSVToColor(hueVal, 1, 1))
            surface.DrawRect(x, 1, segmentWidth + 1, h - 2)
        end

        RNDX.Rect(huePos - 2, 0, 4, h)
            :Color(colorTarget)
        :Draw()
    end

    local rgbContainer = vgui.Create('Panel', frame)
    rgbContainer:Dock(TOP)
    rgbContainer:SetTall(32)
    rgbContainer:DockMargin(0, 0, 0, 8)

    for _, ch in ipairs({ 'R', 'G', 'B' }) do
        local slot = vgui.Create('Panel', rgbContainer)
        slot:Dock(LEFT)
        slot:DockMargin(0, 0, 8, 0)
        slot:SetWide((frame:GetWide() - 40) / 3)

        local entry = vgui.Create('MantleEntry', slot)
        entry:Dock(FILL)
        entry:SetPlaceholder(ch)
        entry:SetValue(tostring(ch == 'R' and selectedColor.r or ch == 'G' and selectedColor.g or selectedColor.b))
        entry.textEntry:SetNumeric(true)
        entry.textEntry.OnTextChanged = function(s)
            local v = tonumber(s:GetText())
            if v then
                v = math.Clamp(math.Round(v), 0, 255)
                if ch == 'R' then
                    selectedColor.r = v
                elseif ch == 'G' then
                    selectedColor.g = v
                else
                    selectedColor.b = v
                end
                local r, g, b = selectedColor.r / 255, selectedColor.g / 255, selectedColor.b / 255
                local h2, s2, v2 = ColorToHSV(Color(r * 255, g * 255, b * 255))
                hue = h2
                saturation = s2
                value = v2
                timer.Simple(0, function()
                    if IsValid(colorField) and IsValid(hueSlider) then
                        colorCursor.x = saturation * colorField:GetWide()
                        colorCursor.y = (1 - value) * colorField:GetTall()
                        huePos = (hue / 360) * hueSlider:GetWide()
                    end
                end)
            end
        end

        rgbEntries[ch] = entry
    end

    local btnContainer = vgui.Create('Panel', frame)
    btnContainer:Dock(BOTTOM)
    btnContainer:SetTall(32)

    local btnClose = vgui.Create('MantleBtn', btnContainer)
    btnClose:Dock(LEFT)
    btnClose:SetWide(92)
    btnClose:SetRadius(10)
    btnClose:SetTxt(Mantle.lang.get('mantle', 'color_cancel'))
    btnClose.DoClick = function()
        frame:Close()
        Mantle.func.sound()
    end

    local btnSelect = vgui.Create('MantleBtn', btnContainer)
    btnSelect:Dock(RIGHT)
    btnSelect:SetWide(92)
    btnSelect:SetRadius(10)
    btnSelect:SetTxt(Mantle.lang.get('mantle', 'color_select'))
    btnSelect.DoClick = function()
        frame:Close()
        Mantle.func.sound()

        callback(selectedColor)
    end

    timer.Simple(0, function()
        if IsValid(colorField) and IsValid(hueSlider) then
            colorCursor.x = saturation * colorField:GetWide()
            colorCursor.y = (1 - value) * colorField:GetTall()
            huePos = (hue / 360) * hueSlider:GetWide()
        end
    end)
end
