local fileExists = file.Exists
local fileWrite = file.Write
local fileCreateDir = file.CreateDir
local getPathFromFilename = string.GetPathFromFilename
local find = string.find
local fetch = http.Fetch
local getMaterial = Material

local errorMat = getMaterial('error')
local webImageCache = {}
local pendingLoads = {}

local function getCacheKey(url, path)
    return url .. '\0' .. path
end

local function getCachedMaterial(cacheKey, path)
    local cached = webImageCache[cacheKey]
    if cached then
        return cached
    end

    if fileExists(path, 'DATA') then
        local material = getMaterial('data/' .. path, 'noclamp mips')
        webImageCache[cacheKey] = material
        return material
    end
end

local function flushPending(cacheKey, material)
    local callbacks = pendingLoads[cacheKey]
    if !callbacks then return end

    pendingLoads[cacheKey] = nil

    for _, callback in ipairs(callbacks) do
        callback(material)
    end
end

local function ensureDataPath(path)
    local dir = getPathFromFilename(path)
    if dir != '' then
        fileCreateDir(dir)
    end
end

--[[
    Функция для скачивания материала по ссылке и его кэшированного использования
]]--
function http.DownloadMaterial(url, path, callback, retryCount)
    local cacheKey = getCacheKey(url, path)
    local cachedMaterial = getCachedMaterial(cacheKey, path)
    if cachedMaterial then
        callback(cachedMaterial)
        return
    end

    if pendingLoads[cacheKey] then
        pendingLoads[cacheKey][#pendingLoads[cacheKey] + 1] = callback
        return
    end

    pendingLoads[cacheKey] = {callback}

    local attemptsLeft = retryCount or 0

    local function loadMaterial()
        fetch(url, function(body)
            if !body or find(body, '<!DOCTYPE HTML>', 1, true) then
                flushPending(cacheKey, errorMat)
                return
            end

            ensureDataPath(path)
            fileWrite(path, body)

            local material = getMaterial('data/' .. path, 'noclamp mips')
            if !material or material:IsError() then
                flushPending(cacheKey, errorMat)
                return
            end

            webImageCache[cacheKey] = material
            flushPending(cacheKey, material)
        end, function()
            if attemptsLeft > 0 then
                attemptsLeft = attemptsLeft - 1
                loadMaterial()
                return
            end

            flushPending(cacheKey, errorMat)
        end)
    end

    loadMaterial()
end
