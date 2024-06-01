function entity.prototype.innerJoin(self, tableName, fromColumn, toColumn)
    if type(fromColumn) == 'table' then
        fromColumn = self:resolveColumn(fromColumn)
    end
    if type(toColumn) == 'table' then
        toColumn = self:resolveColumn(toColumn)
    end
    self.query = self.query .. ' INNER JOIN ' .. tableName .. ' ON ' .. fromColumn .. ' = ' .. toColumn .. ' '

    return self
end

function entity.prototype.join(self, tableName, fromColumn, toColumn)
    self.query = self.query .. ' JOIN ' .. tableName .. ' ON ' .. fromColumn .. ' = ' .. toColumn .. ' '

    return self
end

function entity.prototype.leftJoinQuery(self, tableName, fromColumn, toColumn)
    local query = ' LEFT JOIN ' .. tableName .. ' ON ' .. fromColumn .. ' = ' .. toColumn .. ' '

    return query
end