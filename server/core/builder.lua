local entities = {}

function Entity(name, alias, fields, dbConnection)
    entities[alias] = {
        name = name,
        alias = alias,
        dbConnection = dbConnection,
        fields = filter(fields, function(_, value)
            return value.__type == 'Column'
        end),
        relations = filter(fields, function(_, value)
            return value.__type ~= 'Column'
        end)
    }

    return {
        checkAndCreate = function(dropTable)
            createEntity(name, fields, dropTable, dbConnection)
        end
    }
end

function Column(type, options, order)
    return {
        __type = 'Column',
        type = type,
        options = options,
        order = order
    }
end

function enum(arr)
    local enums = ''

    for enum, _ in pairs(arr) do
        enums = enums .. "'" .. enum .. "', "
    end

    return 'ENUM(' .. enums:sub(1, -3) .. ')'
end

function OneToMany(entityAlias, foreignKey, targetKey)
    return {
        __type = 'OneToMany',
        entityAlias = entityAlias,
        foreignKey = foreignKey,
        targetKey = targetKey
    }
end

function ManyToMany(entityAlias, foreignKey, targetKey)
    return {
        __type = 'ManyToMany',
        entityAlias = entityAlias,
        foreignKey = foreignKey,
        targetKey = targetKey
    }
end

function ManyToOne(entityAlias, foreignKey, targetKey)
    return {
        __type = 'ManyToOne',
        entityAlias = entityAlias,
        foreignKey = foreignKey,
        targetKey = targetKey
    }
end

function OneToOne(entityAlias, foreignKey, targetKey)
    return {
        __type = 'OneToOne',
        entityAlias = entityAlias,
        foreignKey = foreignKey,
        targetKey = targetKey
    }
end

function Date()
    return os.date('%Y-%m-%d %H:%M:%S', os.time())
end

function _entity(alias)
    local entity = entities[alias]
    assert(entity, 'Entity with alias ' .. alias .. ' was not found.')

    if entity.core then
        return entity.core
    end

    entities[alias].core = buildEntity(entity)

    return entities[alias].core
end
