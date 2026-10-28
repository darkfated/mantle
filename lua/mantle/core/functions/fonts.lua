local function createFont(name, family, size)
    surface.CreateFont(name, { font = family, size = size, extended = true })
end

local original = surface.SetFont
local created = {
    ['Fated.16'] = true
}
createFont('Fated.16', 'Montserrat Medium', 16)

function surface.SetFont(font)
    if type(font) != 'string' then
        if font == nil then
            ErrorNoHalt('surface.SetFont called with nil! Using fallback font')
            original('DermaDefault')
            return
        end
        original(font)
        return
    end

    if !created[font] and font:match('^Fated%.') then
        local size, isBold = font:match('^Fated%.(%d+)(b?)$')
        if size then
            createFont(font, isBold == 'b' and 'Montserrat Bold' or 'Montserrat Medium', tonumber(size))
            created[font] = true
        end
    end

    original(font)
end
