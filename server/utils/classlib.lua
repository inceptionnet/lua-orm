function _new()
    ---@type any
    local c = { prototype = {} }
    c.prototype.__index = c.prototype
    c.prototype.constructor = c
    return c
end

function extends(target, base)
    target.____super = base
    ---@type any
    local staticMetatable = setmetatable({ __index = base }, base)
    setmetatable(target, staticMetatable)
    local baseMetatable = getmetatable(base)
    if baseMetatable then
        if type(baseMetatable.__index) == "function" then
            staticMetatable.__index = baseMetatable.__index
        end
        if type(baseMetatable.__newindex) == "function" then
            staticMetatable.__newindex = baseMetatable.__newindex
        end
    end
    setmetatable(target.prototype, base.prototype)
    if type(base.prototype.__index) == "function" then
        target.prototype.__index = base.prototype.__index
    end
    if type(base.prototype.__newindex) == "function" then
        target.prototype.__newindex = base.prototype.__newindex
    end
    if type(base.prototype.__tostring) == "function" then
        target.prototype.__tostring = base.prototype.__tostring
    end
end

---@param target any
---@vararg any
function _load(target, ...)
    ---@type any
    local instance = setmetatable({}, target.prototype)
    instance:constructor(...)
    return instance
end