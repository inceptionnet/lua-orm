function prepareColumn(field)
    local query = ''

    if field.__type == 'Column' then
        query = query .. field.type
        if field.options.length then
            query = query .. '(' .. field.options.length .. ') '
        end
        if field.options.primary then
            query = query .. ' PRIMARY KEY '
        end
        if field.options.autoIncrement then
            query = query .. ' AUTO_INCREMENT '
        end
        if field.options.allowNull then
            query = query .. ' NULL '
        else
            query = query .. ' NOT NULL '
        end

        if field.options.default then
            local defaultType = type(field.options.default)
            if field.options.default == 'NOW()' then
                query = query .. ' DEFAULT NOW() '
            elseif defaultType == 'string' then
                query = query .. ' DEFAULT \'' .. field.options.default .. '\' '
            elseif defaultType == 'number' then
                query = query .. ' DEFAULT ' .. field.options.default .. ' '
            end
        end
    end

    return query
end

function createEntity(name, fields, dropTable, dbConnection)
    dbConnection = dbConnection or mysql:getDBConnection()

    if dropTable and type(dropTable) == 'boolean' then
        local dropQuery = 'DROP TABLE IF EXISTS ' .. name .. ';'
        dbExec(dbConnection, dropQuery)
    end

    local query = 'CREATE TABLE ' .. (not dropTable and 'IF NOT EXISTS' or '') .. ' ' .. name .. ' ('
    local orderedFields = {}

    for fieldName, field in pairs(fields) do
        if field.__type == 'Column' then
            table.insert(orderedFields, { name = fieldName, field = field })
        end
    end

    table.sort(orderedFields, function(a, b)
        return a.field.order < b.field.order
    end)

    local lastFieldType

    for _, data in ipairs(orderedFields) do
        local fieldName = data.name

        if _ == #orderedFields then
            query = query .. fieldName .. ' ' .. prepareColumn(data.field)
        else
            query = query .. fieldName .. ' ' .. prepareColumn(data.field) .. ','
        end

        lastFieldType = data.field.type
    end

    query = query .. ') AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb3;'

    dbExec(dbConnection, query)

    dbQuery(function(qh)
        local res, rows, err = dbPoll(qh, 0)
        if rows > 0 then
            if not res or #res == 0 or rows == 0 then
                return
            end

            local columns = {}

            for _, row in pairs(res) do
                columns[row.Field] = row
            end

            for _, data in ipairs(orderedFields) do
                local fieldExists = columns[data.name]

                if not fieldExists then
                    -- The columns not exists on sql but has entity
                    local addColumnQuery = 'ALTER TABLE ' .. name .. ' ADD COLUMN ' .. data.name .. ' ' .. prepareColumn(data.field)

                    dbExec(dbConnection, addColumnQuery)
                else
                    -- update types
                    local fieldType = prepareColumn(data.field)

                    if data.field.options.default then
                        local updateColumnQuery = 'ALTER TABLE ' .. name .. ' MODIFY COLUMN ' .. data.name .. ' ' .. fieldType
                        dbExec(dbConnection, updateColumnQuery)
                    end
                end
            end

            for columnName in pairs(columns) do
                local fieldExists = fields[columnName]

                if not fieldExists then
                    -- The columns exists on sql but not has entity
                    local dropColumnQuery = 'ALTER TABLE ' .. name .. ' DROP COLUMN ' .. columnName

                    dbExec(dbConnection, dropColumnQuery)
                end
            end
        end
    end, dbConnection, 'DESCRIBE ' .. name)
end
