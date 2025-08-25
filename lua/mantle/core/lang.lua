function Mantle.lang.get(addon, key)
    if !Mantle.lang.list[addon] then
        print('Mantle.lang.get: addon "' .. addon .. '" not found!')
    end

    local lang = GetConVar('gmod_language'):GetString()
    local langTable = Mantle.lang.list[addon][lang]

    if !Mantle.lang.list[addon][lang] then
        langTable = Mantle.lang.list[addon][Mantle.lang.default]
    end

    if !langTable then
        for _, v in pairs(Mantle.lang.list[addon]) do
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
