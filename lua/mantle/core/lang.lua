function Mantle.lang.get(addon, key)
    local addonTable = Mantle.lang.list[addon]
    if not addonTable then
        print('Mantle.lang.get: addon "' .. addon .. '" not found!')
        return key
    end

    local lang = GetConVar('gmod_language'):GetString()
    local langTable = addonTable[lang] or addonTable[Mantle.lang.default]

    if not langTable then
        for _, v in pairs(addonTable) do
            langTable = v
            break
        end
        if not langTable then
            print('Mantle.lang.get: addon "' .. addon .. '" has no language tables!')
            return key
        end
    end

    return langTable[key] or key
end
