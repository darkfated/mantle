local file, Mat, Fetch, find = file, Material, http.Fetch, string.find
local errorMat = Mat('error')
local WebImageCache = {}

--[[
    Функция для скачивания материала по ссылке и его кэшированного использования
]]--
function http.DownloadMaterial(url, path, callback, retry_count)
    if WebImageCache[url] then
        return callback(WebImageCache[url])
    end

    local dataPath = 'data/' .. path

    if file.Exists(path, 'DATA') then
        WebImageCache[url] = Mat(dataPath, 'noclamp mips')

        callback(WebImageCache[url])
    else
        Fetch(url, function(img)
            if !img or find(img, '<!DOCTYPE HTML>', 1, true) then
                return callback(errorMat)
            end

            file.Write(path, img)

            WebImageCache[url] = Mat(dataPath, 'noclamp mips')

            callback(WebImageCache[url])
        end, function()
            if retry_count and retry_count > 0 then
                retry_count = retry_count - 1

                http.DownloadMaterial(url, path, callback, retry_count)
            else
                callback(errorMat)
            end
        end)
    end
end
