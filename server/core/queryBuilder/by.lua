OrderType = {
    DESC = 'DESC'
}

function entity.prototype.groupBy(self, column)
    if type(column) == 'table' then
        column = self:resolveColumn(column)
    end

    self.query = self.query .. ' GROUP BY ' .. column .. ' '
    return self
end

function entity.prototype.orderBy(self, column, order)
    if type(column) == 'table' then
        column = self:resolveColumn(column)
    end

    self.query = self.query .. ' ORDER BY ' .. column .. ' ' .. order
    return self
end