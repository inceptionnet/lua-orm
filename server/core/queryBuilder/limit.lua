function entity.prototype.limit(self, limit)
    self.query = self.query .. ' LIMIT ' .. limit
    return self
end