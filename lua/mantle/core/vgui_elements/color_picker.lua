local color_target = Color(255, 255, 255, 200)

function Mantle.ui.color_picker(func, color_standart)
    if IsValid(Mantle.ui.menu_color_picker) then
        Mantle.ui.menu_color_picker:Remove()
    end

    local selectedColor = color_standart or Color(255, 255, 255)
    local hue = 0
    local saturation = 1
    local value = 1

    if color_standart then
        local r, g, b = color_standart.r / 255, color_standart.g / 255, color_standart.b / 255
        local h, s, v = ColorToHSV(Color(r * 255, g * 255, b * 255))
        hue = h
        saturation = s
        value = v
    end

    Mantle.ui.menu_color_picker = vgui.Create('MantleFrame')
    Mantle.ui.menu_color_picker:SetSize(300, 378)
    Mantle.ui.menu_color_picker:Center()
    Mantle.ui.menu_color_picker:MakePopup()
    Mantle.ui.menu_color_picker:SetTitle('')
    Mantle.ui.menu_color_picker:SetCenterTitle(Mantle.lang.get('mantle', 'color_title'))
    Mantle.ui.menu_color_picker:OnlyCloseBtn()

    local preview = vgui.Create('Panel', Mantle.ui.menu_color_picker)
    preview:Dock(TOP)
    preview:SetTall(40)
    preview:DockMargin(0, 0, 0, 10)
    preview.Paint = function(_, w, h)
        RNDX().Rect(0, 0, w, h)
            :Rad(16)
            :Color(selectedColor)
            :Shape(RNDX.SHAPE_IOS)
        :Draw()

        RNDX().Rect(0, 0, w, h)
            :Rad(16)
            :Color(Mantle.color.outline)
            :Outline(1)
            :Shape(RNDX.SHAPE_IOS)
        :Draw()
    end

    local colorField = vgui.Create('Panel', Mantle.ui.menu_color_picker)
    colorField:Dock(TOP)
    colorField:SetTall(200)
    colorField:DockMargin(0, 0, 0, 10)

    local colorCursor = {
        x = 0,
        y = 0
    }
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
        end
    end

    colorField.Paint = function(self, w, h)
        local segments = 80
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

        RNDX().Rect(0, 0, w, h)
            :Color(Mantle.color.outline)
            :Outline(1)
            :Shape(RNDX.SHAPE_IOS)
        :Draw()

        RNDX().Circle(colorCursor.x, colorCursor.y, 12)
            :Outline(2)
            :Color(color_target)
        :Draw()
    end

    local hueSlider = vgui.Create('Panel', Mantle.ui.menu_color_picker)
    hueSlider:Dock(TOP)
    hueSlider:SetTall(20)
    hueSlider:DockMargin(0, 0, 0, 10)

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
        end
    end

    hueSlider.Paint = function(self, w, h)
        local segments = 100
        local segmentWidth = w / segments

        RNDX().Rect(0, 0, w, h)
            :Color(Mantle.color.window_shadow)
            :Shape(RNDX.SHAPE_IOS)
            :Shadow(5, 20)
        :Draw()

        for i = 0, segments - 1 do
            local hueVal = (i / segments) * 360
            local x = i * segmentWidth

            surface.SetDrawColor(HSVToColor(hueVal, 1, 1))
            surface.DrawRect(x, 1, segmentWidth + 1, h - 2)
        end

        RNDX().Rect(huePos - 2, 0, 4, h)
            :Color(color_target)
        :Draw()
    end

    local rgbContainer = vgui.Create('Panel', Mantle.ui.menu_color_picker)
    rgbContainer:Dock(TOP)
    rgbContainer:SetTall(60)
    rgbContainer:DockMargin(0, 0, 0, 10)

    local btnContainer = vgui.Create('Panel', Mantle.ui.menu_color_picker)
    btnContainer:Dock(BOTTOM)
    btnContainer:SetTall(30)

    local btnClose = vgui.Create('MantleBtn', btnContainer)
    btnClose:Dock(LEFT)
    btnClose:SetWide(90)
    btnClose:SetTxt(Mantle.lang.get('mantle', 'color_cancel'))
    btnClose.DoClick = function()
        Mantle.ui.menu_color_picker:Remove()
        Mantle.func.sound()
    end

    local btnSelect = vgui.Create('MantleBtn', btnContainer)
    btnSelect:Dock(RIGHT)
    btnSelect:SetWide(90)
    btnSelect:SetTxt(Mantle.lang.get('mantle', 'color_select'))
    btnSelect.DoClick = function()
        Mantle.ui.menu_color_picker:Remove()
        Mantle.func.sound()

        func(selectedColor)
    end

    timer.Simple(0, function()
        if IsValid(colorField) and IsValid(hueSlider) then
            colorCursor.x = saturation * colorField:GetWide()
            colorCursor.y = (1 - value) * colorField:GetTall()
            huePos = (hue / 360) * hueSlider:GetWide()
        end
    end)

    timer.Simple(0.1, function()
        Mantle.ui.menu_color_picker:SetAlpha(255)
    end)
end
