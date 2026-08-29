local PANEL = {}

local ELLIPSIS = "..."
local DEFAULT_LINE_H = 16

local function charIter(str)
	return string.gmatch(str, utf8.charpattern)
end

local function measure(font)
	surface.SetFont(font)
	local _, h = surface.GetTextSize("Ay")
	return h > 0 and h or DEFAULT_LINE_H
end

local function getWidth(font, str)
	surface.SetFont(font)
	return surface.GetTextSize(str)
end

local function trimToFit(text, maxw, font)
	if getWidth(font, text) <= maxw then
		return text
	end

	local out = ""
	for ch in charIter(text) do
		if getWidth(font, out .. ch) <= maxw then
			out = out .. ch
		else
			break
		end
	end

	return out
end

local function buildTokens(text)
	local tokens = {}
	local paraIndex = 0

	for para in (text .. "\n"):gmatch("([^\n]*)\n") do
		paraIndex = paraIndex + 1
		local words = 0

		for word in para:gmatch("%S+") do
			tokens[#tokens + 1] = { word = word, newLine = paraIndex > 1 }
			words = words + 1
		end

		if words == 0 then
			tokens[#tokens + 1] = { word = "" }
		end
	end

	return tokens
end

local function wrapAndEllipsize(font, text, maxw, maxLines)
	if maxw <= 0 or maxLines <= 0 then
		return { "" }
	end

	local tokens = buildTokens(text)
	local lines = {}
	local current = {}
	local i, n = 1, #tokens

	local function lineText()
		return table.concat(current, " ")
	end

	while i <= n do
		local tok = tokens[i]

		if tok.word == "" then
			if #current > 0 then
				lines[#lines + 1] = lineText()
				current = {}
			end
			lines[#lines + 1] = ""
		else
			if tok.newLine and #current > 0 then
				lines[#lines + 1] = lineText()
				current = {}
			end

			local cand = #current == 0 and tok.word or (lineText() .. " " .. tok.word)
			if getWidth(font, cand) <= maxw then
				current[#current + 1] = tok.word
			elseif #current > 0 then
				lines[#lines + 1] = lineText()
				current = {}
				current[#current + 1] = tok.word
			else
				local piece = ""
				for ch in charIter(tok.word) do
					if piece ~= "" and getWidth(font, piece .. ch) > maxw then
						lines[#lines + 1] = piece
						piece = ch
					else
						piece = piece .. ch
					end
				end
				current[#current + 1] = piece
			end
		end

		i = i + 1
	end

	if #current > 0 then
		lines[#lines + 1] = lineText()
	end

	if #lines == 0 then
		return { "" }
	end

	if #lines <= maxLines then
		return lines
	end

	local visible = {}
	for k = 1, maxLines - 1 do
		visible[k] = lines[k]
	end

	local rest = {}
	for k = maxLines, #lines do
		rest[#rest + 1] = lines[k]
	end
	local pool = table.concat(rest, " ")

	local fitWidth = math.max(0, maxw - getWidth(font, ELLIPSIS))
	visible[maxLines] = trimToFit(pool, fitWidth, font) .. ELLIPSIS

	return visible
end

local function getTextSize(font, txt)
	surface.SetFont(font)
	local ok, w, h = pcall(surface.GetTextSize, txt)
	if not ok then
		return 0, 16
	end
	if not h or type(h) ~= "number" or h <= 0 then
		local ok2, _, h2 = pcall(surface.GetTextSize, "Ay")
		if ok2 and type(h2) == "number" and h2 > 0 then
			h = h2
		else
			h = 16
		end
	end
	return tonumber(w) or 0, h
end

function PANEL:Init()
	self:DockMargin(8, 8, 8, 8)
	self.text = ""
	self.font = "Fated.16"
	self.align = TEXT_ALIGN_LEFT
	self.valign = TEXT_ALIGN_TOP
	self.padding = 6

	self._lines = { "" }
	self._lineH = 0
	self._lastW, self._lastH = 0, 0
	self._dirty = true

	self:SetMouseInputEnabled(false)
	self:SetKeyboardInputEnabled(false)
	self:SetTooltipPanelOverride("MantleTooltip")
end

function PANEL:SetText(text)
	self.text = tostring(text or "")
	self:InvalidateTextLayout()
end

function PANEL:GetText()
	return self.text
end

function PANEL:SetFont(font)
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
	local strVAlign = valign == "top" and TEXT_ALIGN_TOP
		or valign == "center" and TEXT_ALIGN_CENTER
		or valign == "bottom" and TEXT_ALIGN_BOTTOM

	if strVAlign then
		self.valign = strVAlign
	elseif valign == TEXT_ALIGN_TOP or valign == TEXT_ALIGN_CENTER or valign == TEXT_ALIGN_BOTTOM then
		self.valign = valign
	end
end

function PANEL:SetPadding(padding)
	self.padding = padding
	self:InvalidateTextLayout()
end

function PANEL:GetContentSize()
	local sz_h, len, sz_w = 0, 0, {}
	for _, txt in ipairs(string.Explode("\n", self.text or "")) do
		if #txt < 0 then
			continue
		end

        surface.SetFont(self.font or "Fated.16")
		local tw, th = surface.GetTextSize(txt)
		
        table.insert(sz_w, tw)
		sz_h = sz_h + th
		len = len + 1
	end
	return math.max(unpack(sz_w)), math.max(0, sz_h + self._lineH * (len - 1))
end

function PANEL:InvalidateTextLayout()
	self._dirty = true
	self:InvalidateLayout()
end

function PANEL:_rebuild()
	local w, h = self:GetSize()
	if not self._dirty and w == self._lastW and h == self._lastH then
		return
	end

	self._lastW, self._lastH = w, h
	self._dirty = false

	local availWidth = math.max(1, w - self.padding * 2)
	local lineH = measure(self.font)
	self._lineH = lineH

	local maxLines = math.max(1, math.floor((h - self.padding * 2) / lineH))
	self._lines = wrapAndEllipsize(self.font, self.text, availWidth, maxLines)
end

function PANEL:PerformLayout(w, h)
	self:_rebuild()
end

function PANEL:Paint(w, h)
	self:_rebuild()

	local lines = self._lines
	local lineH = self._lineH
	local totalH = #lines * lineH

	local startY = self.padding
	if self.valign == TEXT_ALIGN_CENTER then
		startY = math.floor((h - totalH) / 2)
	elseif self.valign == TEXT_ALIGN_BOTTOM then
		startY = h - self.padding - totalH
	end

	for i, line in ipairs(lines) do
		local x = self.padding
		if self.align == TEXT_ALIGN_CENTER then
			x = w * 0.5
		elseif self.align == TEXT_ALIGN_RIGHT then
			x = w - self.padding
		end

		draw.SimpleText(
			line,
			self.font,
			x,
			startY + (i - 1) * lineH,
			self.color or Mantle.color.text,
			self.align,
			TEXT_ALIGN_TOP
		)
	end

	return true
end

vgui.Register("MantleText", PANEL, "EditablePanel")