local PANEL = {}

local ELLIPSIS = '...'
local DEFAULT_LINE_H = 16
local math_floor = math.floor

local function charIter(str)
    return string.gmatch(str, utf8.charpattern)
end

local function trimToFit(text, maxw, measureText)
    if maxw <= 0 or measureText(text) <= maxw then
        return maxw > 0 and text or ''
    end

    local chars = {}
    for ch in charIter(text) do
        chars[#chars + 1] = ch
    end

    local low, high = 0, #chars
    while low < high do
        local mid = math_floor((low + high + 1) * 0.5)
        local candidate = table.concat(chars, '', 1, mid)

        if measureText(candidate) <= maxw then
            low = mid
        else
            high = mid - 1
        end
    end

    if low == 0 then return '' end

    local result = {}
    for i = 1, low do
        result[i] = chars[i]
    end

    return table.concat(result)
end

local function splitLongWord(word, maxw, measureText, lines)
    local piece = ''

    for ch in charIter(word) do
        local candidate = piece .. ch
        if piece != '' and measureText(candidate) > maxw then
            lines[#lines + 1] = piece
            piece = ch
        else
            piece = candidate
        end
    end

    return piece
end

local function wrapParagraph(paragraph, maxw, measureText, lines)
    local current = ''
    local hasWords = false

    for word in paragraph:gmatch('%S+') do
        hasWords = true

        if current != '' then
            local candidate = current .. ' ' .. word
            if measureText(candidate) <= maxw then
                current = candidate
            else
                lines[#lines + 1] = current
                current = ''
            end
        end

        if current == '' then
            if measureText(word) <= maxw then
                current = word
            else
                current = splitLongWord(word, maxw, measureText, lines)
            end
        end
    end

    if current != '' then
        lines[#lines + 1] = current
    elseif !hasWords then
        lines[#lines + 1] = ''
    end
end

local function wrapAndEllipsize(text, maxw, maxLines, measureText)
    if maxw <= 0 or maxLines <= 0 then
        return { '' }
    end

    text = string.gsub(text, '\r\n?', '\n')

    local lines = {}
    local startPos = 1

    while true do
        local newlinePos = string.find(text, '\n', startPos, true)
        local paragraph

        if newlinePos then
            paragraph = string.sub(text, startPos, newlinePos - 1)
        else
            paragraph = string.sub(text, startPos)
        end

        wrapParagraph(paragraph, maxw, measureText, lines)

        if !newlinePos then break end
        startPos = newlinePos + 1
    end

    if #lines <= maxLines then
        return lines
    end

    local hasHiddenText = false
    for i = maxLines + 1, #lines do
        if lines[i] != '' then
            hasHiddenText = true
            break
        end
    end

    local visible = {}
    for i = 1, maxLines do
        visible[i] = lines[i]
    end

    if !hasHiddenText then
        return visible
    end

    local remaining = {}
    for i = maxLines, #lines do
        if lines[i] != '' then
            remaining[#remaining + 1] = lines[i]
        end
    end

    local pool = table.concat(remaining, ' ')
    if measureText(pool) <= maxw then
        visible[maxLines] = pool
        return visible
    end

    if measureText(ELLIPSIS) > maxw then
        visible[maxLines] = trimToFit(pool, maxw, measureText)
        return visible
    end

    local function measureWithEllipsis(value)
        return measureText(value .. ELLIPSIS)
    end

    local prefix = trimToFit(pool, maxw, measureWithEllipsis)
    prefix = string.gsub(prefix, '[%s%.]+$', '')
    visible[maxLines] = prefix .. ELLIPSIS

    return visible
end

function PANEL:Init()
    self:DockMargin(8, 8, 8, 8)
    self.text = ''
    self.font = 'Fated.16'
    self.align = TEXT_ALIGN_LEFT
    self.valign = TEXT_ALIGN_TOP
    self.padding = 6

    self._lines = { '' }
    self._lineH = DEFAULT_LINE_H
    self._horizontalPadding = self.padding
    self._verticalPadding = self.padding
    self._innerHeight = 0
    self._lastW, self._lastH = 0, 0
    self._dirty = true

    self:SetMouseInputEnabled(false)
    self:SetKeyboardInputEnabled(false)
end

function PANEL:SetText(text)
    text = tostring(text or '')
    if self.text == text then return end

    self.text = text
    self:InvalidateTextLayout()
end

function PANEL:GetText()
    return self.text
end

function PANEL:SetFont(font)
    font = tostring(font or self.font)
    if self.font == font then return end

    self.font = font
    self:InvalidateTextLayout()
end

function PANEL:SetColor(color)
    self.color = color
end

function PANEL:SetAlign(align)
    self.align = align
end

function PANEL:SetVAlign(valign)
    local strVAlign = valign == 'top' and TEXT_ALIGN_TOP
        or valign == 'center' and TEXT_ALIGN_CENTER
        or valign == 'bottom' and TEXT_ALIGN_BOTTOM

    if strVAlign then
        self.valign = strVAlign
    elseif valign == TEXT_ALIGN_TOP or valign == TEXT_ALIGN_CENTER or valign == TEXT_ALIGN_BOTTOM then
        self.valign = valign
    end
end

function PANEL:SetPadding(padding)
    padding = tonumber(padding) or 0
    if padding != padding then padding = 0 end
    padding = math.max(0, padding)

    if self.padding == padding then return end

    self.padding = padding
    self:InvalidateTextLayout()
end

function PANEL:InvalidateTextLayout()
    self._dirty = true
    self:InvalidateLayout()
end

function PANEL:_rebuild()
    local w, h = self:GetSize()
    if !self._dirty and w == self._lastW and h == self._lastH then return end

    self._lastW, self._lastH = w, h
    self._dirty = false

    surface.SetFont(self.font)

    local _, lineH = surface.GetTextSize('Ay')
    if !lineH or lineH <= 0 then
        lineH = DEFAULT_LINE_H
    end

    self._lineH = lineH

    local horizontalPadding = math.min(self.padding, math.max(0, w * 0.5))
    local verticalPadding = math.min(self.padding, math.max(0, (h - lineH) * 0.5))
    local availWidth = math.max(0, w - horizontalPadding * 2)
    local innerHeight = math.max(0, h - verticalPadding * 2)
    local maxLines = math.max(1, math_floor(innerHeight / lineH))

    local widthCache = {}
    local function measureText(text)
        local width = widthCache[text]
        if width == nil then
            width = surface.GetTextSize(text)
            widthCache[text] = width
        end
        return width
    end

    self._horizontalPadding = horizontalPadding
    self._verticalPadding = verticalPadding
    self._innerHeight = innerHeight
    self._lines = wrapAndEllipsize(self.text, availWidth, maxLines, measureText)
end

function PANEL:PerformLayout(w, h)
    self:_rebuild()
end

function PANEL:Paint(w, h)
    self:_rebuild()

    local lines = self._lines
    local lineH = self._lineH
    local totalH = #lines * lineH
    local horizontalPadding = self._horizontalPadding
    local verticalPadding = self._verticalPadding
    local innerHeight = self._innerHeight

    local startY = verticalPadding
    if totalH <= innerHeight then
        if self.valign == TEXT_ALIGN_CENTER then
            startY = verticalPadding + math_floor((innerHeight - totalH) * 0.5)
        elseif self.valign == TEXT_ALIGN_BOTTOM then
            startY = h - verticalPadding - totalH
        end
    end

    for i, line in ipairs(lines) do
        local x = horizontalPadding
        if self.align == TEXT_ALIGN_CENTER then
            x = w * 0.5
        elseif self.align == TEXT_ALIGN_RIGHT then
            x = w - horizontalPadding
        end

        draw.SimpleText(line, self.font, x, startY + (i - 1) * lineH, self.color or Mantle.color.text, self.align, TEXT_ALIGN_TOP)
    end

    return true
end

vgui.Register('MantleText', PANEL, 'EditablePanel')
