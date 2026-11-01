local PANEL = {}

local math_floor = math.floor
local math_max = math.max
local math_min = math.min
local math_abs = math.abs

local ALIGN = {
    left = TEXT_ALIGN_LEFT,
    center = TEXT_ALIGN_CENTER,
    right = TEXT_ALIGN_RIGHT
}

local VBAR_WIDTH = 4
local VBAR_GAP = 6
local VBAR_RESERVE = VBAR_WIDTH + VBAR_GAP
local HEADER_RADIUS = 12
local ROW_RADIUS = 12

local function normalizeAlign(align)
    if isstring(align) then
        return ALIGN[string.lower(align)] or TEXT_ALIGN_LEFT
    end

    if align == TEXT_ALIGN_LEFT or align == TEXT_ALIGN_CENTER or align == TEXT_ALIGN_RIGHT then
        return align
    end

    return TEXT_ALIGN_LEFT
end

local function textValue(value)
    if value == nil then return '' end
    return tostring(value)
end

function PANEL:Init()
    self.BaseClass.Init(self)

    self.scrollStep = 500

    self.columns = {}
    self.rows = {}
    self._rowOrder = setmetatable({}, {__mode = 'k'})
    self._rowSerial = 0

    self.headerHeight = 36
    self.rowHeight = 38
    self.font = 'Fated.18'
    self.rowFont = 'Fated.16'
    self.padding = 12
    self.sidePadding = 14

    self.selectedRow = nil
    self._selectedData = nil
    self.sortColumn = nil
    self.sortDesc = true
    self.contextMenuEnabled = true

    self.OnAction = function() end
    self.OnRightClick = function() end

    self._columnWidths = {}
    self._columnStarts = {}
    self._headerButtons = {}
    self._rowPanels = {}
    self._hoverRow = nil
    self._hoverY = 0
    self._hoverA = 0
    self._vbarAlpha = 0
    self._vbarGripY = 0
    self._vbarGripH = 0
    self._needLayout = true
    self._headerDirty = true
    self._poolDirty = true
    self._draggingGrip = false
    self._gripOffset = 0

    self.viewport = vgui.Create('Panel', self)
    self.viewport:SetMouseInputEnabled(true)
    self.viewport:SetKeyboardInputEnabled(false)
    self.viewport:SetZPos(1)
    self.viewport.OnMousePressed = function(_, mouseCode)
        self:OnMousePressed(mouseCode)
    end
    self.viewport.OnMouseWheeled = function(_, delta)
        return self:OnMouseWheeled(delta)
    end
    self.viewport.Paint = function() end

    self.content = self.content or vgui.Create('Panel', self)
    self.content:SetParent(self.viewport)
    self.content:SetMouseInputEnabled(true)
    self.content:SetKeyboardInputEnabled(false)
    self.content:SetPos(0, 0)
    self.content.Paint = function() end
    self.content.OnMousePressed = function(_, mouseCode)
        self:OnMousePressed(mouseCode)
    end
    self.content.OnMouseWheeled = function(_, delta)
        return self:OnMouseWheeled(delta)
    end

    self:_createHeader()
    self:_createHoverBar()
    self:_createVBar()

    self.OnSizeChanged = function()
        self:_markDirty()
    end
end

function PANEL:_isInternal(child)
    return child == self.viewport
        or child == self.content
        or child == self.header
        or child == self.vbar
        or (IsValid(self.vbar) and child == self.vbar.btnGrip)
end

function PANEL:_createHeader()
    if !IsValid(self.header) then
        self.header = vgui.Create('MantlePanel', self)
        self.header:SetMouseInputEnabled(true)
        self.header:SetKeyboardInputEnabled(false)
        self.header:SetColorAlpha(1)
        self.header:SetRadius(HEADER_RADIUS)
        self.header:SetZPos(5)
        self.header.OnMouseWheeled = function(_, delta)
            return self:OnMouseWheeled(delta)
        end
    end

end

function PANEL:_createHoverBar()
    if IsValid(self._hoverBar) then return end

    self._hoverBar = vgui.Create('Panel', self.content)
    self._hoverBar:SetMouseInputEnabled(false)
    self._hoverBar:SetKeyboardInputEnabled(false)
    self._hoverBar:SetZPos(-10)
    self._hoverBar.Paint = function(_, w, h)
        local alpha = self._hoverA
        if alpha <= 0.01 then return end

        local hover = Mantle.color.hover_overlay
        RNDX.Rect(0, 0, w, h)
            :Rad(ROW_RADIUS)
            :Color(Color(hover.r, hover.g, hover.b, math_floor(hover.a * alpha)))
        :Draw()
    end
end

function PANEL:_createVBar()
    if IsValid(self.vbar) then return end

    self.vbar = vgui.Create('Panel', self)
    self.vbar:SetMouseInputEnabled(true)
    self.vbar:SetKeyboardInputEnabled(false)
    self.vbar:SetWide(VBAR_WIDTH)
    self.vbar:SetZPos(20)
    self.vbar.Paint = function(_, w, h)
        local alpha = self._vbarAlpha
        if alpha <= 0.01 then return end

        local color = Mantle.color.gray or Mantle.color.text
        RNDX.Rect(0, 3, w, math_max(0, h - 6))
            :Rad(32)
            :Color(Color(color.r, color.g, color.b, math_floor((color.a or 255) * alpha)))
        :Draw()
    end

    self.vbar.btnGrip = vgui.Create('Panel', self.vbar)
    self.vbar.btnGrip:SetMouseInputEnabled(true)
    self.vbar.btnGrip:SetKeyboardInputEnabled(false)
    self.vbar.btnGrip:SetCursor('hand')
    self.vbar.btnGrip.Paint = function(_, w, h)
        local alpha = self._vbarAlpha
        if alpha <= 0.01 then return end

        local color = Mantle.color.text
        local width = math_min(4, w)
        local x = (w - width) * 0.5

        RNDX.Rect(x, 0, width, h)
            :Rad(32)
            :Color(Color(color.r, color.g, color.b, math_floor((color.a or 255) * alpha)))
        :Draw()
    end

    self.vbar.btnGrip.OnMousePressed = function(s, mouseCode)
        if mouseCode != MOUSE_LEFT then return end

        local parent = s:GetParent()
        local _, mouseY = parent:CursorPos()

        self._draggingGrip = true
        self.drag = false
        self.vel = 0
        self._springing = false
        self._springVelocity = 0
        self._gripOffset = mouseY - s.y
        self.lastInput = CurTime()

        s:MouseCapture(true)
    end

    self.vbar.btnGrip.OnMouseReleased = function(s, mouseCode)
        if mouseCode != MOUSE_LEFT or !self._draggingGrip then return end

        self._draggingGrip = false
        s:MouseCapture(false)
        self.lastInput = CurTime()

        local maxScroll = self:_range()
        self.offset = math.Clamp(self.offset, 0, maxScroll)
        self:_applyScroll()
    end

    self.vbar.OnMousePressed = function(pnl, mouseCode)
        if mouseCode != MOUSE_LEFT then return end

        local _, mouseY = pnl:CursorPos()
        local gripY = pnl.btnGrip.y
        local gripH = pnl.btnGrip:GetTall()
        local page = math_max(1, self._viewHeight * 0.85)

        if mouseY < gripY then
            self:SetScroll(self.offset - page)
        elseif mouseY > gripY + gripH then
            self:SetScroll(self.offset + page)
        end
    end

    self.vbar.OnMouseWheeled = function(_, delta)
        return self:OnMouseWheeled(delta)
    end
end

function PANEL:_getHeaderHeight()
    return #self.columns > 0 and self.headerHeight or 0
end

function PANEL:_getContentHeight()
    return #self.rows * self.rowHeight
end

function PANEL:_updateColumns(contentWidth)
    local count = #self.columns
    local starts = self._columnStarts
    local widths = self._columnWidths

    if count == 0 then return end

    local innerWidth = math_max(0, contentWidth - self.sidePadding * 2)
    local desiredTotal = 0

    for i = 1, count do
        desiredTotal = desiredTotal + math_max(1, math_floor(self.columns[i].width or 100))
    end

    local usedWidth = 0
    if desiredTotal > innerWidth and innerWidth > 0 then
        local scale = innerWidth / desiredTotal

        for i = 1, count - 1 do
            local width = math_max(1, math_floor((self.columns[i].width or 100) * scale))
            widths[i] = width
            usedWidth = usedWidth + width
        end

        widths[count] = math_max(1, innerWidth - usedWidth)
    else
        for i = 1, count - 1 do
            local width = math_max(1, math_floor(self.columns[i].width or 100))
            widths[i] = width
            usedWidth = usedWidth + width
        end

        widths[count] = math_max(1, innerWidth - usedWidth)
    end

    local x = self.sidePadding
    for i = 1, count do
        starts[i] = x
        x = x + widths[i]
    end
end

function PANEL:_layoutHeader()
    if !IsValid(self.header) then return end

    local headerHeight = self:_getHeaderHeight()
    self.header:SetPos(self.padL, self.padT)
    self.header:SetSize(self._contentWidth, headerHeight)
    self.header:SetVisible(headerHeight > 0)

    for i, button in ipairs(self._headerButtons) do
        if IsValid(button) then
            button:SetPos(self._columnStarts[i] or self.sidePadding, 0)
            button:SetSize(self._columnWidths[i] or 0, headerHeight)
        end
    end

end

function PANEL:_getHoveredRow()
    local hovered = vgui.GetHoveredPanel()
    if !IsValid(hovered) then return nil end

    while IsValid(hovered) and hovered != self do
        if hovered._mantleTableOwner == self then
            return hovered
        end

        hovered = hovered:GetParent()
    end

    return nil
end

function PANEL:_updateHover(ft)
    local hovered = self:_getHoveredRow()
    self._hoverRow = hovered

    if IsValid(hovered) and hovered:IsVisible() and hovered._index then
        local targetY = (hovered._index - 1) * self.rowHeight - self.offset
        self._hoverA = Mantle.func.approachExp(self._hoverA, 1, 28, ft)
        self._hoverY = Mantle.func.approachExp(self._hoverY, targetY, 28, ft)

        if math_abs(self._hoverY - targetY) < 0.35 then
            self._hoverY = targetY
        end
    else
        self._hoverA = Mantle.func.approachExp(self._hoverA, 0, 20, ft)
    end

    if IsValid(self._hoverBar) then
        self._hoverBar:SetPos(0, math_floor(self._hoverY))
        self._hoverBar:SetSize(self._contentWidth, self.rowHeight)
    end
end

function PANEL:_ensureRowPool()
    local viewHeight = self._viewHeight or 0
    local poolSize = math_max(1, math.ceil(viewHeight / math_max(1, self.rowHeight)) + 2)

    if !self._poolDirty and #self._rowPanels == poolSize then return end

    while #self._rowPanels < poolSize do
        self:_createRowPanel(#self._rowPanels + 1)
    end

    while #self._rowPanels > poolSize do
        local row = table.remove(self._rowPanels)
        if IsValid(row) then row:Remove() end
    end

    self._poolDirty = false
end

function PANEL:_assignRow(row, index)
    local rowCount = #self.rows
    local data = self.rows[index]

    row._index = index
    row._data = data
    row:SetVisible(index <= rowCount)

    if index > rowCount then return end

    local y = (index - 1) * self.rowHeight - self.offset
    row:SetPos(0, math_floor(y))
    row:SetSize(self._contentWidth, self.rowHeight)
end

function PANEL:_layoutRows()
    self:_ensureRowPool()

    local firstIndex = math_max(1, math_floor(self.offset / math_max(1, self.rowHeight)) + 1)

    for poolIndex, row in ipairs(self._rowPanels) do
        self:_assignRow(row, firstIndex + poolIndex - 1)
    end

    if IsValid(self._hoverBar) then
        self._hoverBar:SetSize(self._contentWidth, self.rowHeight)
        self._hoverBar:SetPos(0, math_floor(self._hoverY))
    end
end

function PANEL:_layoutTable()
    local w, h = self:GetSize()
    local headerHeight = self:_getHeaderHeight()
    local viewWidth = math_max(0, w - self.padL - self.padR)
    local viewHeight = math_max(0, h - self.padT - self.padB - headerHeight)
    local contentHeight = self:_getContentHeight()
    local hasOverflow = contentHeight > viewHeight + 0.5
    local contentWidth = math_max(0, viewWidth - (hasOverflow and VBAR_RESERVE or 0))

    self._viewWidth = viewWidth
    self._viewHeight = viewHeight
    self._contentWidth = contentWidth
    self._contentHeight = contentHeight

    self.viewport:SetPos(self.padL, self.padT + headerHeight)
    self.viewport:SetSize(contentWidth, viewHeight)

    self.content:SetPos(0, 0)
    self.content:SetSize(contentWidth, viewHeight)

    self:_updateColumns(contentWidth)
    self:CreateHeader()
    self:_layoutHeader()
    self:_layoutRows()

    self.vbar:SetVisible(hasOverflow)
    self.vbar:SetPos(self.padL + contentWidth + VBAR_GAP, self.padT + headerHeight)
    self.vbar:SetSize(VBAR_WIDTH, viewHeight)
end

function PANEL:_range()
    local w, h = self:GetSize()
    local headerHeight = self:_getHeaderHeight()
    local viewHeight = math_max(0, h - self.padT - self.padB - headerHeight)
    local contentHeight = self:_getContentHeight()

    local oldWidth = self._contentWidth
    local oldHeight = self._viewHeight
    local oldHeader = self._layoutHeaderHeight
    local oldRowHeight = self._layoutRowHeight
    local oldPool = self._layoutPoolSize

    local viewWidth = math_max(0, w - self.padL - self.padR)
    local hasOverflow = contentHeight > viewHeight + 0.5
    local contentWidth = math_max(0, viewWidth - (hasOverflow and VBAR_RESERVE or 0))
    local poolSize = math_max(1, math.ceil(viewHeight / math_max(1, self.rowHeight)) + 2)

    if self._needLayout
        or oldWidth != contentWidth
        or oldHeight != viewHeight
        or oldHeader != headerHeight
        or oldRowHeight != self.rowHeight
        or oldPool != poolSize
    then
        self:_layoutTable()
        self._needLayout = false
        self._layoutHeaderHeight = headerHeight
        self._layoutRowHeight = self.rowHeight
        self._layoutPoolSize = poolSize
    end

    local maxScroll = math_max(0, contentHeight - viewHeight)
    return maxScroll, viewHeight, contentHeight
end

function PANEL:_applyScroll()
    if !IsValid(self.content) then return end

    self:_layoutRows()
end

function PANEL:_afterScroll(ft, maxScroll, viewHeight, contentHeight)
    local bar = self.vbar
    if !IsValid(bar) then return end

    self:_updateHover(ft)


    if !bar:IsVisible() or maxScroll <= 0 then
        self._vbarAlpha = Mantle.func.approachExp(self._vbarAlpha, 0, 6, ft)
        self._vbarGripY = 0
        self._vbarGripH = 0
        bar.btnGrip:SetSize(VBAR_WIDTH, 0)
        return
    end

    local now = CurTime()
    local hovered = bar:IsHovered() or bar.btnGrip:IsHovered()
    local moving = self.drag or self._draggingGrip or self._springing or math_abs(self.vel) > 6
    local recentlyUsed = self.lastInput > 0 and now - self.lastInput < 0.85
    local visible = hovered or moving or recentlyUsed

    self._vbarAlpha = Mantle.func.approachExp(self._vbarAlpha, visible and 1 or 0, visible and 16 or 5, ft)

    local trackHeight = bar:GetTall()
    if trackHeight <= 0 then return end

    local ratio = math_min(1, viewHeight / math_max(1, contentHeight))
    local gripHeight = math_min(trackHeight, math_max(28, math_floor(trackHeight * ratio)))
    local scrollRange = math_max(0, trackHeight - gripHeight)
    local clampedOffset = math.Clamp(self.offset, 0, maxScroll)
    local targetY = maxScroll <= 0 and 0 or scrollRange * (clampedOffset / maxScroll)

    if self._draggingGrip then
        local _, mouseY = bar:CursorPos()
        local gripY = math.Clamp(mouseY - self._gripOffset, 0, scrollRange)
        self.offset = scrollRange <= 0 and 0 or (gripY / scrollRange) * maxScroll
        self.vel = 0
        self._springing = false
        self._springVelocity = 0
        targetY = gripY
    else
        self._vbarGripY = Mantle.func.approachExp(self._vbarGripY, targetY, 18, ft)
    end

    self._vbarGripH = gripHeight

    if math_abs(self._vbarGripY - targetY) < 0.35 then
        self._vbarGripY = targetY
    end

    bar.btnGrip:SetPos(0, math_floor(self._vbarGripY))
    bar.btnGrip:SetSize(VBAR_WIDTH, self._vbarGripH)
end

function PANEL:CreateHeader()
    if !IsValid(self.header) then
        self:_createHeader()
    end

    if !self._headerDirty and #self._headerButtons == #self.columns then return end

    for _, button in ipairs(self._headerButtons) do
        if IsValid(button) then button:Remove() end
    end

    self._headerButtons = {}

    for index, column in ipairs(self.columns) do
        local columnIndex = index
        local button = vgui.Create('Button', self.header)
        button:SetText('')
        button:SetMouseInputEnabled(column.sortable == true)
        button:SetKeyboardInputEnabled(false)

        button.DoClick = function()
            self:SortByColumn(columnIndex)
            Mantle.func.sound()
        end

        button.Paint = function(_, w, h)
            local color = button:IsHovered() and Mantle.color.theme or Mantle.color.text
            draw.SimpleText(column.name or '', self.font, w * 0.5, h * 0.5, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        self._headerButtons[columnIndex] = button
    end

    self._headerDirty = false
end

function PANEL:_createRowPanel(poolIndex)
    local row = vgui.Create('Button', self.content)
    row:SetText('')
    row:SetMouseInputEnabled(true)
    row:SetKeyboardInputEnabled(false)
    row:SetZPos(2)
    row._mantleTableOwner = self
    row._poolIndex = poolIndex
    row._index = 0
    row._data = nil
    row._selectedAlpha = 0

    row.DoClick = function(s)
        if !s._data then return end

        self._selectedData = s._data
        self.selectedRow = s._index

        if self.OnAction then
            self.OnAction(s._data, s._index)
        end

        Mantle.func.sound()
    end

    row.DoRightClick = function(s)
        if !s._data then return end

        local rowData = s._data
        local rowIndex = s._index

        self._selectedData = rowData
        self.selectedRow = rowIndex

        if self.OnRightClick then
            self.OnRightClick(rowData, rowIndex)
        end

        if !self.contextMenuEnabled or !IsValid(self) then return end

        local menu = Mantle.ui.derma_menu()
        if !IsValid(menu) then return end

        self._contextMenu = menu

        for columnIndex, column in ipairs(self.columns) do
            local name = column.name or ''
            menu:AddOption(Mantle.lang.get('mantle', 'table_copy') .. ' ' .. name, function()
                SetClipboardText(textValue(rowData[columnIndex]))
            end)
        end

        menu:AddSpacer()
        menu:AddOption(Mantle.lang.get('mantle', 'table_delete_row'), function()
            if IsValid(self) then
                self:RemoveItem(rowData)
            end
        end, 'icon16/delete.png')
    end

    row.Paint = function(s, w, h)
        local dt = FrameTime()
        local selected = self._selectedData == s._data
        s._selectedAlpha = Mantle.func.approachExp(s._selectedAlpha, selected and 1 or 0, 20, dt)

        if s._selectedAlpha > 0.01 then
            local color = Mantle.color.theme
            RNDX.Rect(0, 0, w, h)
                :Rad(ROW_RADIUS)
                :Color(Color(color.r, color.g, color.b, math_floor(color.a * s._selectedAlpha * 0.22)))
            :Draw()
        end

        if !s._data then return end

        surface.SetFont(self.rowFont)

        for columnIndex, column in ipairs(self.columns) do
            local colX = self._columnStarts[columnIndex] or 0
            local colW = self._columnWidths[columnIndex] or 0
            local value = textValue(s._data[columnIndex])
            local align = column.align or TEXT_ALIGN_LEFT

            local x
            if align == TEXT_ALIGN_RIGHT then
                x = colX + colW - self.padding
            elseif align == TEXT_ALIGN_CENTER then
                x = colX + colW * 0.5
            else
                x = colX + self.padding
            end

            draw.SimpleText(value, self.rowFont, x, h * 0.5, Mantle.color.text, align, TEXT_ALIGN_CENTER)
        end
    end

    self._rowPanels[poolIndex] = row
    return row
end

function PANEL:AddColumn(name, width, align, sortable)
    self.columns[#self.columns + 1] = {
        name = tostring(name or ''),
        width = math_max(1, tonumber(width) or 100),
        align = normalizeAlign(align),
        sortable = sortable == true
    }

    self._headerDirty = true
    self:_markDirty()
    self:InvalidateLayout(true)
end

function PANEL:AddItem(...)
    local argumentCount = select('#', ...)
    if #self.columns == 0 or argumentCount != #self.columns then
        print(Mantle.lang.get('mantle', 'table_wrong_args'))
        return
    end

    local rowData = {...}
    self._rowSerial = self._rowSerial + 1
    self._rowOrder[rowData] = self._rowSerial
    self.rows[#self.rows + 1] = rowData

    self:_markDirty()

    return #self.rows
end

function PANEL:SortByColumn(columnIndex, descending)
    columnIndex = tonumber(columnIndex)
    if !columnIndex or columnIndex < 1 or columnIndex > #self.columns then return false end

    local column = self.columns[columnIndex]
    if !column.sortable then return false end

    local hasValue = false
    local numeric = true
    local prepared = {}

    for index, row in ipairs(self.rows) do
        local value = row[columnIndex]
        local item = {
            data = row,
            serial = self._rowOrder[row] or index
        }

        if value == nil then
            item.kind = 0
        else
            hasValue = true
            local number = tonumber(value)
            if number == nil or number != number then
                numeric = false
            end
        end

        prepared[index] = item
    end

    if self.sortColumn != columnIndex then
        self.sortColumn = columnIndex
        self.sortDesc = hasValue and numeric or false
    elseif type(descending) == 'boolean' then
        self.sortDesc = descending
    else
        self.sortDesc = !self.sortDesc
    end

    if type(descending) == 'boolean' then
        self.sortDesc = descending
    end

    local desc = self.sortDesc

    for _, item in ipairs(prepared) do
        local value = item.data[columnIndex]
        if value == nil then
            item.kind = 0
            item.key = nil
        elseif numeric then
            item.kind = 1
            item.key = tonumber(value)
        else
            item.kind = 2
            item.key = string.lower(tostring(value))
        end
    end

    table.sort(prepared, function(a, b)
        if a.kind != b.kind then
            return a.kind > b.kind
        end

        if a.kind == 0 then
            return a.serial < b.serial
        end

        if a.key != b.key then
            if desc then
                return a.key > b.key
            end

            return a.key < b.key
        end

        return a.serial < b.serial
    end)

    for index, item in ipairs(prepared) do
        self.rows[index] = item.data
    end

    if self._selectedData then
        self.selectedRow = self:GetRowIndex(self._selectedData)
    else
        self.selectedRow = nil
    end

    self:_markDirty()
    return true
end

function PANEL:RemoveRow(index)
    index = tonumber(index)
    if !index or index < 1 or index > #self.rows or index != math_floor(index) then return false end

    local removed = table.remove(self.rows, index)
    if removed == self._selectedData then
        self._selectedData = nil
        self.selectedRow = nil
    elseif self._selectedData then
        self.selectedRow = self:GetRowIndex(self._selectedData)
    end

    self:_markDirty()
    return true
end

function PANEL:RemoveItem(rowData)
    for index, row in ipairs(self.rows) do
        if row == rowData then
            return self:RemoveRow(index)
        end
    end

    return false
end

function PANEL:SetCellValue(rowIndex, columnIndex, value)
    rowIndex = tonumber(rowIndex)
    columnIndex = tonumber(columnIndex)

    if !rowIndex or !columnIndex then return false end
    if rowIndex < 1 or rowIndex > #self.rows then return false end
    if !self.columns[columnIndex] then return false end

    self.rows[rowIndex][columnIndex] = value
    return true
end

function PANEL:GetCellValue(rowIndex, columnIndex)
    local row = self.rows[rowIndex]
    if !row then return nil end
    return row[columnIndex]
end

function PANEL:GetRow(index)
    return self.rows[index]
end

function PANEL:GetRowIndex(rowData)
    for index, row in ipairs(self.rows) do
        if row == rowData then return index end
    end
end

function PANEL:GetRowCount()
    return #self.rows
end

function PANEL:GetColumnCount()
    return #self.columns
end

function PANEL:GetSelectedRow()
    if self._selectedData then return self._selectedData end
    return self.selectedRow and self.rows[self.selectedRow] or nil
end

function PANEL:SetSelectedRow(index)
    index = tonumber(index)
    if index == nil then
        self.selectedRow = nil
        self._selectedData = nil
        return true
    end

    if index < 1 or index > #self.rows or index != math_floor(index) then return false end

    self.selectedRow = index
    self._selectedData = self.rows[index]
    return true
end

function PANEL:ClearSelection()
    self.selectedRow = nil
    self._selectedData = nil
end

function PANEL:SetAction(func)
    self.OnAction = isfunction(func) and func or function() end
end

function PANEL:SetRightClickAction(func)
    self.OnRightClick = isfunction(func) and func or function() end
end

function PANEL:SetContextMenuEnabled(enabled)
    self.contextMenuEnabled = enabled == true
end

function PANEL:SetHeaderHeight(height)
    height = tonumber(height)
    if !height then return end

    self.headerHeight = math_max(0, math_floor(height))
    self._poolDirty = true
    self:_markDirty()
end

function PANEL:SetRowHeight(height)
    height = tonumber(height)
    if !height then return end

    self.rowHeight = math_max(1, math_floor(height))
    self._poolDirty = true
    self:_markDirty()
end

function PANEL:SetFont(font)
    if !font then return end
    self.font = font
end

function PANEL:SetRowFont(font)
    if !font then return end
    self.rowFont = font
end

function PANEL:SetPadding(padding)
    padding = tonumber(padding)
    if !padding then return end
    self.padding = math_max(0, padding)
end

function PANEL:SetSidePadding(padding)
    padding = tonumber(padding)
    if !padding then return end

    self.sidePadding = math_max(0, padding)
    self:_markDirty()
end

function PANEL:Clear()
    self.rows = {}
    self._rowOrder = setmetatable({}, {__mode = 'k'})
    self._rowSerial = 0
    self.selectedRow = nil
    self._selectedData = nil
    self.sortColumn = nil
    self.sortDesc = true
    self.offset = 0
    self.vel = 0
    self.drag = false
    self._draggingGrip = false
    self._hoverRow = nil
    self._hoverA = 0
    self._hoverY = 0
    self:_markDirty()
end

function PANEL:OnMousePressed(mouseCode)
    if mouseCode != MOUSE_LEFT then return end

    local hovered = vgui.GetHoveredPanel()
    if IsValid(hovered) then
        if hovered == self.header or Mantle.util.isDescendantOf(hovered, self.header) then return end
        if hovered == self.vbar or Mantle.util.isDescendantOf(hovered, self.vbar) then return end
    end

    self.BaseClass.OnMousePressed(self, mouseCode)
end

function PANEL:OnMouseReleased(mouseCode)
    self.BaseClass.OnMouseReleased(self, mouseCode)
end

function PANEL:PerformLayout()
    self:_markDirty()
end

function PANEL:Think()
    self.BaseClass.Think(self)
end

function PANEL:OnRemove()
    if self._draggingGrip and IsValid(self.vbar) and IsValid(self.vbar.btnGrip) then
        self._draggingGrip = false
        self.vbar.btnGrip:MouseCapture(false)
    end

    if IsValid(self._contextMenu) then
        self._contextMenu:CloseMenu()
    end

    if self.BaseClass.OnRemove then
        self.BaseClass.OnRemove(self)
    end
end

vgui.Register('MantleTable', PANEL, 'MantleScroll')
