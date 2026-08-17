local PANEL = {}

local math_floor = math.floor
local math_max = math.max

function PANEL:Init()
    self.BaseClass.Init(self)

    self.scrollStep = 500

    self._topShadowA = 0

    self.columns = {}
    self.rows = {}
    self.headerHeight = 36
    self.rowHeight = 38
    self.font = 'Fated.18'
    self.rowFont = 'Fated.16'
    self.selectedRow = nil
    self.sortColumn = nil
    self.sortDesc = true
    self.padding = 12
    self.sidePadding = 14
    self.vbarW = 4

    self.OnAction = function() end
    self.OnRightClick = function() end

    self:_createHeaderPanel()

    self.vbar = vgui.Create('Panel', self)
    self.vbar:SetMouseInputEnabled(true)
    self.vbar:SetWide(self.vbarW)
    self.vbar:Dock(RIGHT)
    self.vbar.Paint = function() end

    self.vbar.grip = vgui.Create('Panel', self.vbar)
    self.vbar.grip:SetMouseInputEnabled(true)
    self.vbar.grip:SetCursor('hand')
    self.vbar.grip.Paint = function(s, w, h)
        RNDX.Rect(0, 0, w, h)
            :Rad(32)
            :Color(Mantle.color.theme)
        :Draw()
    end
    self.vbar.grip.OnMousePressed = function(s)
        local _, my = self.vbar:CursorPos()
        self._draggingGrip = true
        self._gripOffset = my - s.y
        s:MouseCapture(true)
        self.vel = 0
    end
    self.vbar.grip.OnMouseReleased = function(s)
        self._draggingGrip = false
        s:MouseCapture(false)
    end

    self:DockPadding(0, 0, 0, 0)

    self._headerButtons = {}
    self._colWidthsTarget = {}
    self._colWidthsCurrent = {}
    self._lastVBarVis = false
    self._needWidths = true
    self._draggingGrip = false
    self._gripOffset = 0

    self._hoverX = 0
    self._hoverY = 0
    self._hoverW = 0
    self._hoverH = 0
    self._hoverA = 0

    self.OnSizeChanged = function()
        self._needWidths = true
    end
end

function PANEL:_createHeaderPanel()
    if !IsValid(self._topShadow) then
        self._topShadow = vgui.Create('Panel', self)
        self._topShadow:SetMouseInputEnabled(false)
        self._topShadow.Paint = function(_, w, h)
            local sa = Mantle.color.blur_shadow
            local a = self._topShadowA or 0

            if Mantle.ui.convar.smooth and a > 0 then
                RNDX.Rect(0, 0, w, h)
                    :Blur()
                    :Fade(1, 0)
                    :Alpha(sa.a > 0 and a / sa.a or 0)
                :Draw()
            end
        end
    end

    if !IsValid(self.header) then
self.header = vgui.Create('MantlePanel', self.content)
    self.header:SetMouseInputEnabled(false)
    self.header:Dock(TOP)
    self.header:DockMargin(0, 0, 0, 0)
    self.header:SetTall(self.headerHeight)
    self.header:SetColorAlpha(1)
    self.header:SetRadius(12)
    end

    if !IsValid(self.headerText) then
        self.headerText = vgui.Create('Panel', self)
        self.headerText:SetMouseInputEnabled(true)
        self.headerText:SetSize(self:GetWide(), self.headerHeight)
        self.headerText.Paint = function() end
        self.headerText.OnMouseWheeled = function(_, delta)
            self:OnMouseWheeled(delta)
        end
    end
end

function PANEL:_isInternal(child)
    return child == self.content or child == self.header or child == self.headerText or child == self._topShadow or child == self.vbar or child == self.vbar.grip
end

function PANEL:Think()
    self.BaseClass.Think(self)
    local ft = FrameTime()
    local sa = Mantle.color.blur_shadow

    local topTarget = sa.a * math.min(1, self.offset / self.headerHeight)
    self._topShadowA = Mantle.util.stepAlpha(self._topShadowA, topTarget, 200, ft)
end

function PANEL:_sizeCanvas()
    self.content:SizeToChildren(false, true)
end

function PANEL:_range()
    if self._needLayout then
        local w, h = self:GetWide(), self:GetTall()

        local vbReserve = self.vbar:IsVisible() and self.vbarW or 0

        self.content:SetPos(self.padL, self.padT - self.offset)
        self.content:SetWide(math.max(0, w - self.padL - self.padR - vbReserve))
        self.content:InvalidateLayout(true)
        self.content:SizeToChildren(false, true)

        local viewH = math.max(0, h - self.padT - self.padB)
        local contentH = self.content:GetTall()

        if contentH <= viewH then
            self.vbar:SetVisible(false)
            self.content:SetWide(math.max(0, w - self.padL - self.padR))
            self.content:InvalidateLayout(true)
            self.content:SizeToChildren(false, true)
            contentH = self.content:GetTall()
        else
            self.vbar:SetVisible(true)
        end

        self._needLayout = false
    end

    local viewH = math.max(0, self:GetTall() - self.padT - self.padB)
    local contentH = self.content:GetTall()

    return math.max(0, contentH - viewH), viewH, contentH
end

function PANEL:_applyScroll()
    self.content:SetPos(self.padL, self.padT - math_floor(self.offset))
end

function PANEL:AddColumn(name, width, align, sortable)
    table.insert(self.columns, {
        name = name,
        width = width or 100,
        align = align or TEXT_ALIGN_LEFT,
        sortable = sortable or false
    })
end

function PANEL:AddItem(...)
    local args = {...}
    if #args != #self.columns then
        print(Mantle.lang.get('mantle', 'table_wrong_args'))
        return
    end

    table.insert(self.rows, args)
    self:RebuildRows()
    return #self.rows
end

function PANEL:SortByColumn(columnIndex)
    local column = self.columns[columnIndex]
    if !column or !column.sortable then return end

    if self.sortColumn != columnIndex then
        self.sortColumn = columnIndex

        local numCount, total = 0, 0
        for _, row in ipairs(self.rows) do
            local v = row[columnIndex]
            if v != nil then
                total = total + 1
                if tonumber(tostring(v)) then numCount = numCount + 1 end
            end
        end

        local isNumeric = (total > 0 and numCount >= math.ceil(total / 2))
        self.sortDesc = isNumeric
    else
        self.sortDesc = !self.sortDesc
    end

    local desc = self.sortDesc

    table.sort(self.rows, function(a, b)
        local va = a[columnIndex]
        local vb = b[columnIndex]

        if va == nil and vb == nil then return false end
        if va == nil then return !desc end
        if vb == nil then return desc end

        local sa = tostring(va)
        local sb = tostring(vb)

        local na = tonumber(sa)
        local nb = tonumber(sb)

        if na and nb then
            if desc then
                return na > nb
            else
                return na < nb
            end
        end

        if na and !nb then
            return desc
        elseif nb and !na then
            return !desc
        end

        local la = string.lower(sa)
        local lb = string.lower(sb)
        if desc then
            return la > lb
        else
            return la < lb
        end
    end)

    self:RebuildRows()
end

function PANEL:UpdateColumnWidthTargets()
    local cols = self.columns
    local n = #cols
    if n == 0 then return end

    local panelW = self:GetWide() or 0
    if panelW <= 0 then panelW = ScrW() end

    local vbarVisible = IsValid(self.vbar) and self.vbar:IsVisible()
    local vbarW = vbarVisible and self.vbarW or 0

    local usable = math_max(0, panelW - self.sidePadding * 2 - vbarW)

    local used = 0
    for i = 1, math_max(0, n - 1) do
        self._colWidthsTarget[i] = cols[i].width or 100
        used = used + self._colWidthsTarget[i]
    end

    local lastMin = cols[n].width or 100
    local remaining = usable - used
    if remaining < lastMin then remaining = lastMin end
    self._colWidthsTarget[n] = remaining

    for i = 1, n do
        if self._colWidthsCurrent[i] == nil then
            self._colWidthsCurrent[i] = self._colWidthsTarget[i]
        end
    end

    self._lastVBarVis = vbarVisible
end

function PANEL:_layout()
    local w = self:GetWide()
    local h = self:GetTall()
    local blurTall = math_max(self.headerHeight, h * 0.2)
    self._topShadow:SetSize(w, blurTall)
    self._topShadow:SetPos(0, 0)
    self.headerText:SetSize(w, self.headerHeight)
    self.headerText:SetPos(0, 0)

    local x = self.sidePadding
    for i, btn in ipairs(self._headerButtons) do
        local colW = math_floor(self._colWidthsCurrent[i] or self._colWidthsTarget[i] or 100)
        if IsValid(btn) then
            btn:SetSize(colW, self.headerHeight)
            btn:SetPos(x, 0)
        end
        x = x + colW
    end

    for _, row in ipairs(self._rowPanels) do
        if IsValid(row) then
            local x2 = self.sidePadding
            for i, cell in ipairs(row._cells) do
                local colW = math_floor(self._colWidthsCurrent[i] or self._colWidthsTarget[i] or 100)
                if IsValid(cell) then
                    cell:SetSize(colW, self.rowHeight)
                    cell:SetPos(x2, 0)
                end
                x2 = x2 + colW
            end
        end
    end
end

function PANEL:OnMousePressed(mc)
    local hovered = vgui.GetHoveredPanel()
    if IsValid(hovered) and (hovered == self.headerText or Mantle.util.isDescendantOf(hovered, self.headerText) or hovered == self.vbar or Mantle.util.isDescendantOf(hovered, self.vbar)) then
        return
    end

    self.BaseClass.OnMousePressed(self, mc)
end

function PANEL:OnMouseReleased(mc)
    self._draggingGrip = false
    self.BaseClass.OnMouseReleased(self, mc)
end

function PANEL:_afterScroll(ft, maxScroll, viewH, contentH)
    local vbarVisible = IsValid(self.vbar) and self.vbar:IsVisible()
    if vbarVisible != self._lastVBarVis then
        self._lastVBarVis = vbarVisible
        self._needWidths = true
    end

    local needLayout = self._needWidths
    if self._needWidths then
        self:UpdateColumnWidthTargets()
        self._needWidths = false
    end

    local changed = false
    for i = 1, #self.columns do
        local tgt = self._colWidthsTarget[i] or (self.columns[i] and self.columns[i].width or 100)
        local cur = self._colWidthsCurrent[i]
        if cur and cur != tgt then
            cur = Mantle.func.approachExp(cur, tgt, 20, ft)
            self._colWidthsCurrent[i] = cur
            if math.abs(cur - tgt) < 0.5 then
                cur = tgt
                self._colWidthsCurrent[i] = cur
            end
            changed = true
        end
    end

    if changed or needLayout then
        self:_layout()
    end

    local vb = self.vbar
    if !vb:IsVisible() then return end

    local gripH = math.max(24, math.floor(vb:GetTall() * (viewH / math.max(1, contentH))))

    if self._draggingGrip then
        local _, my = vb:CursorPos()
        local range = math.max(0, vb:GetTall() - gripH)
        if range > 0 then
            local dragY = math.Clamp(my - self._gripOffset, 0, range)
            self.offset = (dragY / range) * maxScroll
            self.vel = 0
        end
        self:_applyScroll()
    end

    local scroll01 = maxScroll <= 0 and 0 or (self.offset / maxScroll)
    local y = math.max(0, vb:GetTall() - gripH) * scroll01

    vb.grip:SetSize(vb:GetWide(), gripH)
    vb.grip:SetPos(0, y)
end

function PANEL:CreateHeader()
    self:_createHeaderPanel()

    self.headerText:Clear()
    self._headerButtons = {}

    self:UpdateColumnWidthTargets()

    for i, column in ipairs(self.columns) do
        local btn = vgui.Create('Button', self.headerText)
        btn:SetText('')
        btn:SetSize(100, self.headerHeight)

        btn.Paint = function(_, bw, bh)
            local active = (self.sortColumn == i) or btn:IsHovered()
            local textColor = active and Mantle.color.theme or Mantle.color.text

            draw.SimpleText(column.name, self.font, bw * 0.5, bh * 0.5, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        if column.sortable then
            btn.DoClick = function()
                self:SortByColumn(i)
                Mantle.func.sound()
            end
        end

        self._headerButtons[i] = btn
    end

    self._needWidths = true
end

function PANEL:CreateRow(rowIndex, rowData)
    local row = vgui.Create('Button', self.content)
    row:Dock(TOP)
    row:SetTall(self.rowHeight)
    row:SetText('')

    row._index = rowIndex
    row._selectedAlpha = 0
    row._cells = {}

    row.Paint = function(s, w, h)
        local dt = FrameTime()
        s._selectedAlpha = Mantle.func.approachExp(s._selectedAlpha, (self.selectedRow == s._index) and 1 or 0, 22, dt)

        local base = Mantle.color.focus_panel
        local selCol = Mantle.color.theme

        local blendA = s._selectedAlpha

        local r = Lerp(blendA, base.r, selCol.r)
        local g = Lerp(blendA, base.g, selCol.g)
        local b = Lerp(blendA, base.b, selCol.b)
        local a = Lerp(blendA, base.a, selCol.a)

        surface.SetDrawColor(Color(math.floor(r), math.floor(g), math.floor(b), math.floor(a)))
        surface.DrawRect(0, h - 1, w, 1)
    end

    row.DoClick = function()
        self.selectedRow = rowIndex
        self.OnAction(rowData)
        Mantle.func.sound()
    end

    row.DoRightClick = function()
        self.selectedRow = rowIndex
        self.OnRightClick(rowData)
        local menu = Mantle.ui.derma_menu()
        for i, column in ipairs(self.columns) do
            menu:AddOption(Mantle.lang.get('mantle', 'table_copy') .. ' ' .. column.name, function()
                SetClipboardText(tostring(rowData[i]))
            end)
        end
        menu:AddSpacer()
        menu:AddOption(Mantle.lang.get('mantle', 'table_delete_row'), function()
            self:RemoveRow(rowIndex)
        end, 'icon16/delete.png')
    end

    for i, column in ipairs(self.columns) do
        local cell = vgui.Create('Panel', row)
        cell:SetMouseInputEnabled(false)
        cell:SetSize(100, self.rowHeight)
        cell:SetPos(0, 0)

        local text = tostring(rowData[i])
        local align = column.align or TEXT_ALIGN_LEFT

        cell.Paint = function(_, w, h)
            local x
            local textAlign
            if align == TEXT_ALIGN_RIGHT then
                x = w - self.padding - self.sidePadding
                textAlign = TEXT_ALIGN_RIGHT
            elseif align == TEXT_ALIGN_CENTER then
                x = w * 0.5
                textAlign = TEXT_ALIGN_CENTER
            else
                x = self.padding
                textAlign = TEXT_ALIGN_LEFT
            end
            draw.SimpleText(text, self.rowFont, x, h * 0.5, Mantle.color.text, textAlign, TEXT_ALIGN_CENTER)
        end

        row._cells[i] = cell
    end

    table.insert(self._rowPanels, row)
end

function PANEL:RebuildRows()
    self.content:Clear()
    self._rowPanels = {}

    if IsValid(self._hoverBar) then
        self._hoverBar:Remove()
    end

    self._hoverBar = vgui.Create('Panel', self.content)
    self._hoverBar:SetMouseInputEnabled(false)
    local hoverColor = Mantle.color.hover_overlay
    self._hoverBar.Paint = function(_, w, h)
        local a = self._hoverA
        if a <= 0.01 then return end
        RNDX.Rect(0, 0, w, h)
            :Rad(12)
            :Color(Color(hoverColor.r, hoverColor.g, hoverColor.b, math.floor(hoverColor.a * a)))
        :Draw()
    end
    self._hoverBar.Think = function()
        local ft = FrameTime()
        local speed = 60

        local hovered
        for _, row in ipairs(self._rowPanels) do
            if IsValid(row) and row:IsHovered() then
                hovered = row
                break
            end
        end
        self._hoverRow = hovered

        if IsValid(hovered) then
            self._hoverA = Mantle.func.approachExp(self._hoverA, 1, speed, ft)
            self._hoverX = Mantle.func.approachExp(self._hoverX, hovered:GetX(), speed, ft)
            self._hoverY = Mantle.func.approachExp(self._hoverY, hovered:GetY(), speed, ft)
            self._hoverW = Mantle.func.approachExp(self._hoverW, hovered:GetWide(), speed, ft)
            self._hoverH = Mantle.func.approachExp(self._hoverH, hovered:GetTall(), speed, ft)

            if math.abs(self._hoverX - hovered:GetX()) < 0.5 then self._hoverX = hovered:GetX() end
            if math.abs(self._hoverY - hovered:GetY()) < 0.5 then self._hoverY = hovered:GetY() end
            if math.abs(self._hoverW - hovered:GetWide()) < 0.5 then self._hoverW = hovered:GetWide() end
            if math.abs(self._hoverH - hovered:GetTall()) < 0.5 then self._hoverH = hovered:GetTall() end
        else
            self._hoverA = Mantle.func.approachExp(self._hoverA, 0, 20, ft)
        end

        self._hoverBar:SetPos(self._hoverX, self._hoverY)
        self._hoverBar:SetSize(self._hoverW, self._hoverH)
    end

    self:CreateHeader()

    for rowIndex, rowData in ipairs(self.rows) do
        self:CreateRow(rowIndex, rowData)
    end

    self._needWidths = true
    self:_markDirty()
    self:InvalidateLayout(true)
end

function PANEL:SetAction(func)
    self.OnAction = func
end

function PANEL:SetRightClickAction(func)
    self.OnRightClick = func
end

function PANEL:Clear()
    self.rows = {}
    self.selectedRow = nil
    self.content:Clear()
    self.offset = 0
    self.vel = 0
    self:_markDirty()
end

function PANEL:GetSelectedRow()
    return self.selectedRow and self.rows[self.selectedRow] or nil
end

function PANEL:GetRowCount()
    return #self.rows
end

function PANEL:RemoveRow(index)
    if index and index > 0 and index <= #self.rows then
        table.remove(self.rows, index)
        if self.selectedRow == index then
            self.selectedRow = nil
        elseif self.selectedRow and self.selectedRow > index then
            self.selectedRow = self.selectedRow - 1
        end
        self:RebuildRows()
    end
end

vgui.Register('MantleTable', PANEL, 'MantleScroll')
