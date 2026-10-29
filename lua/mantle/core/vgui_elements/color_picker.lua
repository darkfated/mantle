local FRAME_W = 320
local FRAME_H = 400
local PREVIEW_H = 40
local FIELD_H = 194
local HUE_H = 22
local ROW_H = 32
local GAP = 8
local SLOT_GAP = 8
local CURSOR_SIZE = 6
local CURSOR_COLOR = Color(255, 255, 255, 200)

local CHANNELS = { 'R', 'G', 'B' }

local math_clamp = math.Clamp
local math_floor = math.floor
local math_max = math.max
local math_round = math.Round

local function getChannel(color, channel)
    if channel == 'R' then return color.r end
    if channel == 'G' then return color.g end

    return color.b
end

local function setChannel(color, channel, value)
    if channel == 'R' then
        color.r = value
    elseif channel == 'G' then
        color.g = value
    else
        color.b = value
    end
end

local function attachDrag(panel, onMove)
    panel.OnMousePressed = function(self, keyCode)
        if keyCode != MOUSE_LEFT then return end

        self._dragging = true
        self:MouseCapture(true)
        onMove(self, self:CursorPos())
    end

    panel.OnMouseReleased = function(self, keyCode)
        if keyCode != MOUSE_LEFT or !self._dragging then return end

        self._dragging = false
        self:MouseCapture(false)
    end

    panel.OnCursorMoved = function(self, x, y)
        if !self._dragging then return end

        onMove(self, x, y)
    end

    panel.OnRemove = function(self)
        if !self._dragging then return end

        self._dragging = false
        self:MouseCapture(false)
    end
end

local function createField(parent)
    local panel = vgui.Create('Panel', parent)
    panel:Dock(TOP)
    panel:DockMargin(0, 0, 0, GAP)
    panel:SetTall(FIELD_H)

    panel.hue = 0
    panel.sat = 1
    panel.val = 1
    panel._columns = {}
    panel._columnsWide = -1
    panel._columnsHue = -1

    function panel:SetValue(hue, sat, val)
        self.hue = hue
        self.sat = sat
        self.val = val
    end

    function panel:_getColumns(w)
        if self._columnsWide == w and self._columnsHue == self.hue then
            return self._columns
        end

        local columns = self._columns
        local hueColor = HSVToColor(self.hue, 1, 1)
        local last = math_max(w - 1, 1)

        for x = 0, w - 1 do
            local factor = x / last
            local index = x * 3

            columns[index + 1] = math_floor(255 + (hueColor.r - 255) * factor + 0.5)
            columns[index + 2] = math_floor(255 + (hueColor.g - 255) * factor + 0.5)
            columns[index + 3] = math_floor(255 + (hueColor.b - 255) * factor + 0.5)
        end

        self._columnsWide = w
        self._columnsHue = self.hue

        return columns
    end

    attachDrag(panel, function(self, x, y)
        local w, h = self:GetSize()
        if w <= 0 or h <= 0 then return end

        x = math_clamp(x, 0, w)
        y = math_clamp(y, 0, h)

        self:SetValue(self.hue, x / w, 1 - y / h)

        if self.OnValueChanged then
            self.OnValueChanged(self.sat, self.val)
        end
    end)

    panel.Paint = function(self, w, h)
        if w <= 0 or h <= 0 then return end

        local columns = self:_getColumns(w)

        for x = 0, w - 1 do
            local index = x * 3
            surface.SetDrawColor(columns[index + 1], columns[index + 2], columns[index + 3], 255)
            surface.DrawRect(x, 0, 1, h)
        end

        local last = math_max(h - 1, 1)

        for y = 0, h - 1 do
            surface.SetDrawColor(0, 0, 0, math_floor(255 * y / last))
            surface.DrawRect(0, y, w, 1)
        end

        RNDX.Rect(0, 0, w, h)
            :Color(Mantle.color.window_shadow)
            :Outline(1)
        :Draw()

        RNDX.Circle(self.sat * w, (1 - self.val) * h, CURSOR_SIZE)
            :Outline(2)
            :Color(CURSOR_COLOR)
        :Draw()
    end

    return panel
end

local function createHueBar(parent)
    local panel = vgui.Create('Panel', parent)
    panel:Dock(TOP)
    panel:DockMargin(0, 0, 0, GAP)
    panel:SetTall(HUE_H)

    panel.hue = 0
    panel._columns = {}
    panel._columnsWide = -1

    function panel:SetValue(hue)
        self.hue = hue
    end

    function panel:_getColumns(w)
        if self._columnsWide == w then
            return self._columns
        end

        local columns = self._columns
        local last = math_max(w - 1, 1)

        for x = 0, w - 1 do
            local color = HSVToColor(x / last * 360, 1, 1)
            local index = x * 3

            columns[index + 1] = color.r
            columns[index + 2] = color.g
            columns[index + 3] = color.b
        end

        self._columnsWide = w

        return columns
    end

    attachDrag(panel, function(self, x)
        local w = self:GetWide()
        if w <= 0 then return end

        x = math_clamp(x, 0, w)
        self:SetValue(x / w * 360)

        if self.OnValueChanged then
            self.OnValueChanged(self.hue)
        end
    end)

    panel.Paint = function(self, w, h)
        if w <= 0 or h <= 0 then return end

        local columns = self:_getColumns(w)

        for x = 0, w - 1 do
            local index = x * 3
            surface.SetDrawColor(columns[index + 1], columns[index + 2], columns[index + 3], 255)
            surface.DrawRect(x, 1, 1, h - 2)
        end

        RNDX.Rect(self.hue / 360 * w - 2, 0, 4, h)
            :Color(CURSOR_COLOR)
        :Draw()
    end

    return panel
end

function Mantle.ui.color_picker(callback, defaultColor)
    if IsValid(Mantle.ui.menu_color_picker) then
        Mantle.ui.menu_color_picker:Remove()
    end

    local selectedColor = Color(255, 255, 255, 255)

    if defaultColor then
        selectedColor.r = defaultColor.r
        selectedColor.g = defaultColor.g
        selectedColor.b = defaultColor.b
        selectedColor.a = defaultColor.a or 255
    end

    local hue, sat, val = ColorToHSV(selectedColor)
    hue = hue or 0
    sat = sat or 1
    val = val or 1

    local entries = {}
    local syncing = false

    local frame = vgui.Create('MantleFrame')
    Mantle.ui.menu_color_picker = frame
    frame:SetSize(FRAME_W, FRAME_H)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle('')
    frame:SetCenterTitle(Mantle.lang.get('mantle', 'color_title'))
    frame:ShowAnimation()
    frame:SetPopupPad(12)

    local preview = vgui.Create('MantlePanel', frame)
    preview:Dock(TOP)
    preview:DockMargin(0, 0, 0, GAP)
    preview:SetTall(PREVIEW_H)
    preview:SetRadius(16)
    preview:SetCustomColor(selectedColor)

    local field = createField(frame)
    local hueBar = createHueBar(frame)

    field:SetValue(hue, sat, val)
    hueBar:SetValue(hue)

    local function syncEntries(skip)
        syncing = true

        for _, channel in ipairs(CHANNELS) do
            local entry = entries[channel]

            if channel != skip and IsValid(entry) then
                local value = tostring(getChannel(selectedColor, channel))

                if entry:GetValue() != value then
                    entry.textEntry:SetText(value)
                end
            end
        end

        syncing = false
    end

    local function pushState(skip)
        preview:SetCustomColor(selectedColor)
        field:SetValue(hue, sat, val)
        hueBar:SetValue(hue)
        syncEntries(skip)
    end

    local function setColorFromHSV()
        local color = HSVToColor(hue, sat, val)

        selectedColor.r = color.r
        selectedColor.g = color.g
        selectedColor.b = color.b
    end

    field.OnValueChanged = function(newSat, newVal)
        sat, val = newSat, newVal

        setColorFromHSV()
        pushState()
    end

    hueBar.OnValueChanged = function(newHue)
        hue = newHue

        setColorFromHSV()
        pushState()
    end

    local row = vgui.Create('Panel', frame)
    row:Dock(TOP)
    row:DockMargin(0, 0, 0, GAP)
    row:SetTall(ROW_H)
    row.slots = {}

    local function layoutSlots(panel, w)
        if w <= 0 then return end

        local slotWide = math_floor((w - SLOT_GAP * 2) / 3)

        for i, slot in ipairs(panel.slots) do
            local wide = i < 3 and slotWide or (w - slotWide * 2 - SLOT_GAP * 2)

            if slot:GetWide() != wide then
                slot:SetWide(wide)
            end
        end
    end

    row.OnSizeChanged = layoutSlots

    for i, channel in ipairs(CHANNELS) do
        local slot = vgui.Create('Panel', row)
        slot:Dock(LEFT)
        slot:DockMargin(0, 0, i < 3 and SLOT_GAP or 0, 0)
        slot:SetWide(1)

        local entry = vgui.Create('MantleEntry', slot)
        entry:Dock(FILL)
        entry:DockMargin(0, 2, 0, 2)
        entry:SetPlaceholder(channel)
        entry.textEntry:SetNumeric(true)
        entry.textEntry:SetText(tostring(getChannel(selectedColor, channel)))

        entry.textEntry.OnTextChanged = function(self)
            if syncing then return end

            local value = tonumber(self:GetText())
            if !value then return end

            value = math_clamp(math_round(value), 0, 255)
            setChannel(selectedColor, channel, value)

            local newHue, newSat, newVal = ColorToHSV(selectedColor)

            if newSat and newSat > 0 then
                hue = newHue
            end

            sat = newSat or sat
            val = newVal or val

            pushState(channel)
        end

        entry.action = function()
            syncEntries()
        end

        entries[channel] = entry
        table.insert(row.slots, slot)
    end

    layoutSlots(row, row:GetWide())

    local buttons = vgui.Create('Panel', frame)
    buttons:Dock(BOTTOM)
    buttons:SetTall(ROW_H)

    local btnCancel = vgui.Create('MantleBtn', buttons)
    btnCancel:Dock(LEFT)
    btnCancel:DockMargin(0, 0, 0, 0)
    btnCancel:SetWide(92)
    btnCancel:SetTxt(Mantle.lang.get('mantle', 'color_cancel'))
    btnCancel.DoClick = function()
        frame:Close()
        Mantle.func.sound()
    end

    local btnSelect = vgui.Create('MantleBtn', buttons)
    btnSelect:Dock(RIGHT)
    btnSelect:DockMargin(0, 0, 0, 0)
    btnSelect:SetWide(92)
    btnSelect:SetTxt(Mantle.lang.get('mantle', 'color_select'))
    btnSelect.DoClick = function()
        frame:Close()
        Mantle.func.sound()

        callback(Color(selectedColor.r, selectedColor.g, selectedColor.b, selectedColor.a))
    end
end
