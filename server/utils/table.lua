function table:filter(callback)
    local newTable = {}
    for k, v in pairs(self) do
        if callback(v, k) then
            newTable[k] = v
        end
    end
    return newTable
end

function table:count()
    local count = 0
    for _, _ in pairs(self) do
        count = count + 1
    end
    return count
end

function startsWith(str, start)
    return str:sub(1, #start) == start
end
