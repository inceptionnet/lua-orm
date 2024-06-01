SelectQuery = {
    ALL = '*'
}

function entity.prototype.select(self, columns, hasRelations)
    local relations = self:relations()

    if hasRelations and relations then
        columns = columns .. relations.columns

        self.query = 'SELECT ' .. columns .. ' FROM ' .. self.name

        self.query = self.query .. relations.query
    else
        self.query = 'SELECT ' .. columns .. ' FROM ' .. self.name
    end

    return self
end