entity = _new()

function entity.prototype.constructor(self, values)
    self.name = values.name
    self.alias = values.alias
    self.fields = values.fields
    self._relations = values.relations

    self.query = ''
    self.params = {}

    self.store = {}
end

function entity.prototype.new(self, fields, relations)
    local query = 'INSERT INTO ' .. self.name

    local fieldsQuery = ''
    local valuesQuery = ''

    local params = {}
    for key, value in pairs(fields) do
        fieldsQuery = fieldsQuery .. key .. ', '
        valuesQuery = valuesQuery .. '?, '

        table.insert(params, value)
    end

    fieldsQuery = fieldsQuery:sub(1, -3)
    valuesQuery = valuesQuery:sub(1, -3)

    query = query .. ' (' .. fieldsQuery .. ') VALUES (' .. valuesQuery .. ')'

    self.query = query
    self.params = params
    self.relations = relations

    self.db = dbConnect('mysql', 'dbname=' .. _config.database.name .. ';host=' .. _config.database.host, _config.database.username, _config.database.password, 'autoreconnect=1')

    addEventHandler('onResourceStop', resourceRoot, function()
        self.db:destroy()
    end)

    return self
end

function entity.prototype.getCache(self, itemKey, value)
    if type(itemKey) == 'table' then
        itemKey = self:resolveColumn(itemKey)
    end

    if itemKey == 'id' then
        return self.store[tonumber(value)] or self.store[value]
    end

    for _, arrValue in pairs(self.store) do
        local field = tonumber(arrValue[itemKey]) or arrValue[itemKey]
        if field == value then
            return arrValue
        end
    end
    return false
end

function entity.prototype.getMultipleCache(self, itemKey, value)
    if type(itemKey) == 'table' then
        itemKey = self:resolveColumn(itemKey)
    end

    if itemKey == 'id' then
        return self.store[tonumber(value)] or self.store[value]
    end

    return filter(self.store, function(_, arrValue)
        local field = arrValue[itemKey]
        return field == value
    end)
end

function entity.prototype.getAllCache(self)
    return self.store
end

function entity.prototype.setCache(self, key, value)
    self.store[tonumber(key) or key] = value
    return self
end

function entity.prototype.resolveColumn(self, column)
    local key = ''

    for columnName, data in pairs(self.fields) do
        if data.order == column.order then
            key = columnName
            break
        end
    end

    return key
end

function entity.prototype.injectStrToQuery(self, str, ...)
    local params = { ... }
    self.query = self.query .. str

    for _, value in ipairs(params) do
        table.insert(self.params, value)
    end

    return self
end

function entity.prototype.execute(self, callback, dbConnection)
    dbConnection = dbConnection or self.db
    local query = self.query

    if callback then
        dbQuery(function(queryHandler)
            local result, rows, err = dbPoll(queryHandler, 0)
            callback(self:resolveRelations(result), rows, err, query)
        end, dbConnection, query, unpack(self.params))
    else
        local preparedQuery = dbPrepareString(dbConnection, query, unpack(self.params))
        dbExec(dbConnection, preparedQuery)
    end

    self.query = ''
    self.params = {}
end

function entity.prototype.lastQuery(self, callback, key)
    key = key or 'id'
    dbQuery(function(queryHandler)
        local result, rows, err = dbPoll(queryHandler, 0)
        if rows > 0 then
            callback(result, rows, err)
        end
    end, self.db, 'SELECT * FROM `' .. self.name .. '` WHERE `' .. key .. '` = LAST_INSERT_ID()')
end

function buildEntity(values)
    return _load(entity, values)
end
