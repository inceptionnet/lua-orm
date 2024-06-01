local blocks = {}

local function addBlock(path)
    local file = fileOpen(path, true)
    if file then
        local content = fileRead(file, fileGetSize(file))
        fileClose(file)

        table.insert(blocks, content)
    end
end

local function scanCoreModules()
    local xml = xmlLoadFile('meta.xml')
    local files = xmlNodeGetChildren(xml)

    for _, file in ipairs(files) do
        local name = xmlNodeGetAttribute(file, 'src')
        local include = xmlNodeGetAttribute(file, 'include')
        if name and include then
            addBlock(name)
        end
    end
end

function injectModule()
    return table.concat(blocks, ' ')
end

addEventHandler('onResourceStart', resourceRoot, function()
    scanCoreModules()
end)
