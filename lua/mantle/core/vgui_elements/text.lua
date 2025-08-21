local PANEL = {}

local function utf8_iter(s)
    return s:gmatch('([%z\1-\127\194-\244][\128-\191]*)')
end

function PANEL:Init()
    self.text = ''
    self.font = 'Fated.18'
    self.color = Mantle.color.text
    self.align = TEXT_ALIGN_LEFT
    self.valign = 'top'
    self.padding = 6

    self._lines = {''}
    self._line_h = 16
    self._last_w, self._last_h = 0, 0

    self:SetMouseInputEnabled(false)
    self:SetKeyboardInputEnabled(false)
end

function PANEL:SetText(text)
    self.text = text
    self:InvalidateLayout()
end

function PANEL:GetText()
    return self.text
end

function PANEL:SetFont(font)
    self.font = font
    self:InvalidateLayout()
end

function PANEL:SetColor(col)
    self.color = col
    self:InvalidateLayout()
end

function PANEL:SetAlign(a)
    self.align = a
    self:InvalidateLayout()
end

function PANEL:SetVAlign(v)
    if v == 'top' or v == 'center' or v == 'bottom' then
        self.valign = v
        self:InvalidateLayout()
    end
end

function PANEL:SetPadding(p)
    self.padding = p
    self:InvalidateLayout()
end

local function GetTextSize(font, txt)
    surface.SetFont(font)
    local ok, w, h = pcall(surface.GetTextSize, txt)
    if not ok then return 0, 16 end
    if not h or type(h) != 'number' or h <= 0 then
        local ok2, _, h2 = pcall(surface.GetTextSize, 'Ay')
        if ok2 and type(h2) == 'number' and h2 > 0 then
            h = h2
        else
            h = 16
        end
    end
    return tonumber(w) or 0, h
end

local function WrapAndEllipsize(text, font, maxw, max_lines)
    if maxw <= 0 or max_lines <= 0 then
        return {''}, true
    end

    local ell = '...'
    local ell_w = GetTextSize(font, ell)
    local paragraphs = string.Explode('\n', text)
    local lines = {}
    local truncated = false

    for pi = 1, #paragraphs do
        local para = paragraphs[pi]

        if para == '' then
            table.insert(lines, '')
            if #lines >= max_lines then
                truncated = (pi < #paragraphs)
                break
            end
        else
            local words = string.Explode(' ', para)
            local i = 1
            local cur = ''

            while i <= #words do
                local w = words[i]
                local test = (cur == '') and w or (cur .. ' ' .. w)
                local tw = GetTextSize(font, test)
                if tw <= maxw then
                    cur = test
                    i = i + 1
                else
                    if cur != '' then
                        table.insert(lines, cur)
                        cur = ''
                        if #lines >= max_lines then break end
                    else
                        local part = ''

                        for ch in utf8_iter(w) do
                            local tpart = part .. ch
                            local tw2 = GetTextSize(font, tpart)
                            if tw2 <= maxw then
                                part = tpart
                            else
                                if part == '' then
                                    local ch_w = GetTextSize(font, ch)
                                    if ch_w <= maxw then
                                        table.insert(lines, ch)
                                    else
                                        table.insert(lines, ch)
                                    end
                                else
                                    table.insert(lines, part)
                                    local ch_w = GetTextSize(font, ch)
                                    if ch_w <= maxw then
                                        part = ch
                                    else
                                        table.insert(lines, ch)
                                        part = ''
                                    end
                                end
                                part = part or ''

                                if #lines >= max_lines then break end
                            end
                        end
                        if #lines >= max_lines then break end
                        cur = part
                        i = i + 1
                    end
                end
            end

            if #lines < max_lines and cur != '' then
                table.insert(lines, cur)
            end

            if #lines >= max_lines then
                if i <= #words or pi < #paragraphs then
                    truncated = true
                end

                if truncated then
                    local rest = ''
                    if i <= #words then
                        for j = i, #words do
                            rest = rest .. words[j] .. (j < #words and ' ' or '')
                        end
                    end
                    if pi < #paragraphs then
                        for pj = pi + 1, #paragraphs do
                            if paragraphs[pj] != '' then
                                rest = rest .. (rest != '' and ' ' or '') .. paragraphs[pj]
                            end
                        end
                    end

                    if #lines == 0 then
                        lines[1] = ''
                    end

                    local lastIdx = #lines
                    local prev = lines[lastIdx] or ''
                    if rest == '' then
                        rest = prev
                    else
                        rest = prev .. (rest != '' and (' ' .. rest) or '')
                    end

                    local res = ''
                    for ch in utf8_iter(rest) do
                        local t = res .. ch
                        local tw = GetTextSize(font, t)
                        if tw + ell_w <= maxw then
                            res = t
                        else
                            break
                        end
                    end
                    lines[lastIdx] = (res == '' and ell) or (res .. ell)
                end

                break
            end
        end
    end

    if #lines == 0 then lines[1] = '' end
    return lines, truncated
end

function PANEL:_rebuild_if_needed()
    local w, h = self:GetSize()
    if w == self._last_w and h == self._last_h then return end
    self._last_w, self._last_h = w, h

    local avail_w_df = math.max(1, w - self.padding * 2)
    local _, line_h = GetTextSize(self.font, 'Ay')
    self._line_h = line_h or 16

    local max_lines = math.max(1, math.floor((h - self.padding * 2) / self._line_h))
    local lines, trunc = WrapAndEllipsize(self.text, self.font, avail_w_df, max_lines)
    self._lines = lines
    self._truncated = trunc
end

function PANEL:PerformLayout(w, h)
    self:_rebuild_if_needed()
end

function PANEL:Paint(w, h)
    self:_rebuild_if_needed()
    local lines = self._lines or {''}
    local line_h = self._line_h or 16
    local total_h = #lines * line_h

    local start_y = self.padding
    if self.valign == 'center' then
        start_y = math.floor((h - total_h) / 2)
    elseif self.valign == 'bottom' then
        start_y = h - self.padding - total_h
    end

    surface.SetFont(self.font)
    for i = 1, #lines do
        local line = lines[i]
        local y = start_y + (i - 1) * line_h

        local x = self.padding
        if self.align == TEXT_ALIGN_CENTER then
            x = w * 0.5
        elseif self.align == TEXT_ALIGN_RIGHT then
            x = w - self.padding
        end

        draw.SimpleText(line, self.font, x, y, self.color, self.align, TEXT_ALIGN_TOP)
    end

    return true
end

vgui.Register('MantleText', PANEL, 'EditablePanel')
