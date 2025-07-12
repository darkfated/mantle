local PANEL = {}

function PANEL:Init()
    self.columns = {}
    self.rows = {}
    self.headerHeight = 36
    self.rowHeight = 32
    self.font = 'Fated.18'
    self.rowFont = 'Fated.16'
    self.selectedRow = nil
    self.sortColumn = nil
    self.hoverAnim = 0
    self.padding = 8

    self.header = vgui.Create('Panel', self)
    self.header:Dock(TOP)
    self.header:SetTall(self.headerHeight)

    self.scrollPanel = vgui.Create('MantleScrollPanel', self)
    self.scrollPanel:Dock(FILL)
    self.scrollPanel:DockMargin(0, 2, 0, 0)

    self.content = vgui.Create('Panel', self.scrollPanel)
    self.content:Dock(FILL)
    self.content:DockPadding(0, 0, 0, 0)
    self.content.Paint = nil

    self.OnAction = function() end
    self.OnRightClick = function() end
end

function PANEL:AddColumn(name, width, align, sortable)
    table.insert(self.columns, {
        name = name,
        width = width,
        align = align or TEXT_ALIGN_LEFT,
        sortable = sortable or false
    })
end

function PANEL:AddItem(...)
    local args = {...}
    if #args != #self.columns then
        print('MantleTable Error: Неверное количество аргументов')
        return
    end
    
    table.insert(self.rows, args)
    self:RebuildRows()
    return #self.rows
end

function PANEL:SortByColumn(columnIndex)
    local column = self.columns[columnIndex]
    if not column or not column.sortable then return end
    
    self.sortColumn = columnIndex
    
    local function getValueType(value)
        if value == nil then return 'nil' end
        value = tostring(value)
        return tonumber(value) and 'number' or 'string'
    end
    
    local function compareValues(a, b)
        if a == nil and b == nil then return false end
        if a == nil then return true end
        if b == nil then return false end
        
        local typeA = getValueType(a)
        local typeB = getValueType(b)
        
        if typeA != typeB then
            return typeA < typeB
        end
        
        if typeA == 'number' then
            local numA = tonumber(a) or 0
            local numB = tonumber(b) or 0
            return numA > numB
        else
            local strA = tostring(a)
            local strB = tostring(b)
            return strA < strB
        end
    end
    
    local success, err = pcall(function()
        table.sort(self.rows, function(a, b)
            return compareValues(a[columnIndex], b[columnIndex])
        end)
    end)
    
    if not success then
        print('[MantleTable] Ошибка сортировки:', err)
        return
    end
    
    self:RebuildRows()
end

function PANEL:CreateHeader()
    self.header:Clear()
    
    self.header.Paint = function(_, w, h)
        RNDX.Draw(16, 0, 0, w, h, Mantle.color.focus_panel, RNDX.SHAPE_IOS)
    end
    
    local xPos = 0
    for i, column in ipairs(self.columns) do
        local label = vgui.Create('DButton', self.header)
        label:SetText('')
        label:SetSize(column.width, self.headerHeight)
        label:SetPos(xPos, 0)
        
        label.Paint = function(s, w, h)
            local isHovered = s:IsHovered() and column.sortable
            local isActive = self.sortColumn == i
            
            if isHovered then
                RNDX.Draw(16, 0, 0, w, h, Mantle.color.hover, RNDX.SHAPE_IOS)
            end
            
            local textColor = isActive and Mantle.color.theme or color_white
            draw.SimpleText(column.name, self.font, w/2, h/2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        if column.sortable then
            label.DoClick = function()
                self:SortByColumn(i)
                Mantle.func.sound()
            end
        end
        
        xPos = xPos + column.width
    end
end

function PANEL:CreateRow(rowIndex, rowData)
    local row = vgui.Create('DButton', self.content)
    row:Dock(TOP)
    row:DockMargin(0, 1, 0, 0)
    row:SetTall(self.rowHeight)
    row:SetText('')
    
    row.Paint = function(s, w, h)
        local bgColor = self.selectedRow == rowIndex and Mantle.color.theme or 
                       (s:IsHovered() and Mantle.color.hover or Mantle.color.panel_alpha[1])
        RNDX.Draw(16, 0, 0, w, h, bgColor, RNDX.SHAPE_IOS)
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
            menu:AddOption('Копировать ' .. column.name, function()
                SetClipboardText(tostring(rowData[i]))
            end)
        end
        
        menu:AddSpacer()
        menu:AddOption('Удалить строку', function()
            self:RemoveRow(rowIndex)
        end)
    end
    
    local xPos = 0
    for i, column in ipairs(self.columns) do
        local label = vgui.Create('DLabel', row)
        label:SetText(tostring(rowData[i]))
        label:SetFont(self.rowFont)
        label:SetTextColor(color_white)
        label:SetContentAlignment(column.align)
        label:SetSize(column.width, self.rowHeight)
        label:SetPos(xPos, 0)

        if column.align == TEXT_ALIGN_LEFT then
            label:SetTextInset(self.padding, 0)
        elseif column.align == TEXT_ALIGN_RIGHT then
            label:SetTextInset(0, 0, self.padding, 0)
        end

        label:SetContentAlignment(column.align + 4)
        
        xPos = xPos + column.width
    end
end

function PANEL:RebuildRows()
    self.content:Clear()
    self:CreateHeader()

    local totalWidth = 0
    for _, column in ipairs(self.columns) do
        totalWidth = totalWidth + column.width
    end

    for rowIndex, rowData in ipairs(self.rows) do
        self:CreateRow(rowIndex, rowData)
    end

    self.content:SetSize(totalWidth, #self.rows * (self.rowHeight + 1))
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
        self.scrollPanel:InvalidateLayout(true)
    end
end

function PANEL:Paint(w, h)
    RNDX.Draw(16, 0, 0, w, h, Mantle.color.background, RNDX.SHAPE_IOS)
end

vgui.Register('MantleTable', PANEL, 'Panel') 
