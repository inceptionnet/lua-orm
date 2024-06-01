WhereCondition = {
    OR = 'OR',
    AND = 'AND'
}

function entity.prototype.where(self, fields, condition, operator)
    condition = condition or 'AND'
    operator = operator or '='

    local whereUsedBefore = self.query:find('WHERE') ~= nil

    local query = whereUsedBefore and ' ' .. condition .. ' ' or ' WHERE '
    local params = self.params or {}

    for key, value in pairs(fields) do
        if type(key) == 'table' then
            key = self:resolveColumn(key)
        end

        if type(value) == 'table' then
            for _, v in ipairs(value) do
                query = query .. key .. ' ' .. operator .. ' ? ' .. condition .. ' '
                table.insert(params, v)
            end
        else
            query = query .. key .. ' ' .. operator .. ' ? ' .. condition .. ' '
            table.insert(params, value)
        end
    end

    -- For fix last comma
    query = query:sub(1, -5)

    if #params > 0 then
        self.query = self.query .. query
        self.params = params
    end

    return self
end