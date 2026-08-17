local PANEL = {}

local ELLIPSIS = '...'

local function utf8Chars(str)
    return str:gmatch('([%z\1-\127\194-\244][\128-\191]*)')
end

local function measure(font, str)
    surface.SetFont(font)
    local w, h = surface.GetTextSize(str)

    if h <= 0 then
        surface.SetFont(font)
        _, h = surface.GetTextSize('Ay')
    end

    return w or 0, h > 0 and h or 16
end

local function buildTokens(text)
    local tokens = {}
    local paragraphs = string.Explode('\n', text)

    for pi, para in ipairs(paragraphs) do
        local hasWords = false

        for w in string.gmatch(para, '%S+') do
            tokens[#tokens + 1] = { word = w, breakBefore = pi > 1 }
            hasWords = true
        end

        if not hasWords then
            tokens[#tokens + 1] = { word = '', breakBefore = pi > 1 }
        end
    end

    return tokens
end

local function joinTokens(tokens, from, partial)
    local parts = {}

    if partial ~= '' then parts[#parts + 1] = partial end

    for i = from, #tokens do
        parts[#parts + 1] = tokens[i].word
    end

    return table.concat(parts, ' ')
end

local function trimToFit(text, maxw, width)
    if width(text) <= maxw then return text end

    local out = ''
    for ch in utf8Chars(text) do
        if width(out .. ch) <= maxw then
            out = out .. ch
        else
            break
        end
    end

    return out
end

local function splitLongWord(word, maxw, width, emit)
    local chars = {}
    for ch in utf8Chars(word) do chars[#chars + 1] = ch end

    local piece = ''
    for ci = 1, #chars do
        local ch = chars[ci]

        if width(piece .. ch) <= maxw then
            piece = piece .. ch
        elseif piece ~= '' then
            if emit(piece) then
                return '', table.concat(chars, '', ci), true
            end
            piece = ch
        else
            piece = ch
        end
    end

    return piece, '', false
end

local function wrapAndEllipsize(font, text, maxw, maxLines)
    if maxw <= 0 or maxLines <= 0 then
        return {''}, true
    end

    surface.SetFont(font)
    local width = surface.GetTextSize
    local ellWidth = width(ELLIPSIS)

    local lines = {}
    local function emit(line)
        lines[#lines + 1] = line
        return #lines >= maxLines
    end

    local tokens = buildTokens(text)
    local truncated = false
    local restFrom = #tokens + 1
    local restPartial = ''
    local i, line = 1, ''

    while i <= #tokens do
        local tok = tokens[i]

        if tok.word == '' then
            if line ~= '' then
                if emit(line) then
                    truncated = true
                    restFrom = i
                    break
                end
                line = ''
            end

            if emit('') then
                truncated = true
                restFrom = i + 1
                break
            end
        elseif tok.breakBefore and line ~= '' then
            if emit(line) then
                truncated = true
                restFrom = i
                break
            end
            line = ''
        else
            local word = tok.word
            local candidate = (line == '') and word or (line .. ' ' .. word)

            if width(candidate) <= maxw then
                line = candidate
                i = i + 1
            elseif line ~= '' then
                if emit(line) then
                    truncated = true
                    restFrom = i
                    break
                end
                line = ''
            else
                local piece, partial, full = splitLongWord(word, maxw, width, emit)

                if full then
                    truncated = true
                    restFrom = i + 1
                    restPartial = partial
                    break
                end

                line = piece
                i = i + 1
            end
        end

        if truncated then break end
    end

    if not truncated and line ~= '' then
        emit(line)
    end

    if truncated and #lines > 0 then
        local rest = joinTokens(tokens, restFrom, restPartial)
        if rest ~= '' then
            local last = lines[#lines]
            local pool = (last == '') and rest or (last .. ' ' .. rest)
            lines[#lines] = trimToFit(pool, math.max(0, maxw - ellWidth), width) .. ELLIPSIS
        end
    end

    return lines
end

function PANEL:Init()
    self:DockMargin(8, 8, 8, 8)
    self.text = ''
    self.font = 'Fated.16'
    self.color = Mantle.color.text
    self.align = TEXT_ALIGN_LEFT
    self.valign = 'top'
    self.padding = 6

    self._lines = {''}
    self._line_h = 16
    self._last_w, self._last_h = 0, 0
    self._dirty = true

    self:SetMouseInputEnabled(false)
    self:SetKeyboardInputEnabled(false)
end

function PANEL:InvalidateTextLayout()
    self._dirty = true
    self:InvalidateLayout()
end

function PANEL:SetText(text)
    self.text = tostring(text or '')
    self:InvalidateTextLayout()
end

function PANEL:GetText()
    return self.text
end

function PANEL:SetFont(font)
    self.font = font
    self:InvalidateTextLayout()
end

function PANEL:SetColor(col)
    self.color = col
end

function PANEL:SetAlign(align)
    self.align = align
end

function PANEL:SetVAlign(valign)
    if valign == 'top' or valign == 'center' or valign == 'bottom' then
        self.valign = valign
    end
end

function PANEL:SetPadding(padding)
    self.padding = padding
    self:InvalidateTextLayout()
end

function PANEL:_rebuild()
    local w, h = self:GetSize()
    if not self._dirty and w == self._last_w and h == self._last_h then return end

    self._last_w, self._last_h = w, h
    self._dirty = false

    local availWidth = math.max(1, w - self.padding * 2)
    local _, lineH = measure(self.font, 'Ay')
    self._line_h = lineH

    local maxLines = math.max(1, math.floor((h - self.padding * 2) / self._line_h))
    self._lines = wrapAndEllipsize(self.font, self.text, availWidth, maxLines)
end

function PANEL:PerformLayout(w, h)
    self:_rebuild()
end

function PANEL:Paint(w, h)
    self:_rebuild()

    local lines = self._lines or {''}
    local lineH = self._line_h or 16
    local totalH = #lines * lineH

    local startY = self.padding
    if self.valign == 'center' then
        startY = math.floor((h - totalH) / 2)
    elseif self.valign == 'bottom' then
        startY = h - self.padding - totalH
    end

    for i, line in ipairs(lines) do
        local x = self.padding
        if self.align == TEXT_ALIGN_CENTER then
            x = w * 0.5
        elseif self.align == TEXT_ALIGN_RIGHT then
            x = w - self.padding
        end

        draw.SimpleText(line, self.font, x, startY + (i - 1) * lineH, self.color, self.align, TEXT_ALIGN_TOP)
    end

    return true
end

vgui.Register('MantleText', PANEL, 'EditablePanel')
