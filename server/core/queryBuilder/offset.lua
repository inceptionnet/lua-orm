function entity.prototype.offset(self, offset)
    self.query = self.query .. ' OFFSET ' .. offset
    return self
end
