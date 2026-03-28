function Mantle.lang.get(addon, key)
    local addonTable = Mantle.lang.list[addon]
    if !addonTable then
        print('Mantle.lang.get: addon "' .. addon .. '" not found!')
        return key
    end

    local lang = GetConVar('gmod_language'):GetString()
    local langTable = addonTable[lang]

    if !addonTable[lang] then
        langTable = addonTable[Mantle.lang.default]
    end

    if !langTable then
        for _, v in pairs(addonTable) do
            langTable = v
            break
        end
        if !langTable then
            print('Mantle.lang.get: addon "' .. addon .. '" has no language tables!')
            return key
        end
    end

    return langTable[key] or key
end
