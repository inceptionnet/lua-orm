function entity.prototype.hasRelation(self)
    return self._relations and table.count(self._relations) > 0
end

function entity.prototype.relations(self, isSubRelation)
    if self:hasRelation() then
        local relations = {
            query = '',
            columns = ''
        }

        for _, relation in pairs(self._relations) do
            local relationTable = _entity(relation.entityAlias)

            if relation.__type == 'OneToMany' then
                relations.query = relations.query .. self:leftJoinQuery(relationTable.name,
                        self.name .. '.' .. relation.foreignKey,
                        relationTable.name .. '.' .. relation.targetKey)

                for field, _ in pairs(relationTable.fields) do
                    local columnAlias = 'relation_' .. relationTable.name .. '_' .. field
                    relations.columns = relations.columns .. ', ' .. relationTable.name .. '.' .. field .. ' as ' .. columnAlias
                end

                --[[
                if relationTable:hasRelation() then
                    local subRelations = relationTable:relations(true)
                    relations.query = relations.query .. subRelations.query

                    relations.columns = relations.columns .. subRelations.columns
                end
                ]]--
            end
        end

        return relations
    end

    return false
end

function entity.prototype.resultResolver(self, result)
    local nativeResults = {}
    local relationColumnStartsWith = 'relation_'

    for _, row in pairs(result) do
        local nativeRow = filter(row, function(key, _)
            return not startsWith(key, relationColumnStartsWith)
        end)

        table.insert(nativeResults, nativeRow)
    end

    return nativeResults
end

function entity.prototype.relationResolver(self, row)
    local fieldStartsWith = 'relation_' .. self.name .. '_'

    local relationRow = filter(row, function(key)
        return startsWith(key, fieldStartsWith)
    end)

    local relationFields = {}

    for key, value in pairs(relationRow) do
        local field = string.gsub(key, fieldStartsWith, '')
        relationFields[field] = value
    end

    return relationFields
end

function entity.prototype.resolveRelations(self, result)
    if self._relations and table.count(self._relations) > 0 then
        local nativeResults = self:resultResolver(result)
        local newResult = {}

        for key, relation in pairs(self._relations) do
            local relationTable = _entity(relation.entityAlias)
            if relation.__type == 'OneToMany' then
                for _, row in ipairs(result) do
                    local relationResults = relationTable:relationResolver(row, key)
                    local baseID = row[relation.foreignKey]

                    newResult[baseID] = newResult[baseID] or nativeResults[_]

                    newResult[baseID][key] = newResult[baseID][key] or {}
                    table.insert(newResult[baseID][key], relationResults)
                end
            end
        end
        return newResult
    end

    return result
end