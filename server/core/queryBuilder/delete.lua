function entity.prototype.delete(self)
    self.query = 'DELETE FROM ' .. self.name
    return self
end