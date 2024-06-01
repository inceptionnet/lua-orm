function entity.prototype.update(self, fields)
    local query = 'UPDATE ' .. self.name .. ' SET '
    local params = {}

    for key, value in pairs(fields) do
        if type(key) == 'table' then
            key = self:resolveColumn(key)
        end

        query = query .. key .. ' = ?, '
        table.insert(params, value)
    end

    -- For fix last comma
    query = query:sub(1, -3)

    self.query = query
    self.params = params

    return self
end