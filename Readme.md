# Lua ORM

## Description

This is a simple ORM for MTA:SA. It is designed to be simple and easy to use. It is not designed to be a full ORM, but rather a simple way to interact with a database.

#### Note:
- This ORM is not designed to be a full ORM, but rather a simple way to interact with a database.
- This ORM written for MTA:SA.
- We do not recommend to use this ORM, we just publish it for sharing our knowledge. (This ORM was written based on the experiences of 2021.)

## Installation

To install the ORM, simply copy the `orm` folder to your resources folder. Then, inject this resource into your resource like so:

```lua
loadstring(exports.orm:injectModule())()
```

## Usage

### I. Entity

To use the ORM, you must first create a entity. An entity is a class that represents a table in the database. Here is an example of an entity:

```lua
AccountStatus = {
    Active = 'Active',
    Pending = 'Pending',
    Banned = 'Banned',
}

AccountColumn = {
    id = Column(TYPE.INT, { primary = true, autoIncrement = true, length = 0 }, 1),
    username = Column(TYPE.TEXT, { allowNull = true, length = 0 }, 2),
    password = Column(TYPE.VARCHAR, { allowNull = true, length = 32 }, 3),
    status = Column(enum(AccountStatus), { allowNull = true, default = AccountStatus.Pending }, 17),
}

-- Entity('table_name', 'Alias', Column): Entity Class
Entity('accounts', 'Account', AccountColumn)
```

### II. Auto Create Table

If you want to automatically create the table in the database, you can use the `.checkAndCreate()` function. Here is an example:

```lua
Entity('accounts', 'Account', AccountColumn).checkAndCreate()
```

### III. Operations

To interact with the database, you can use the following functions:

#### Insert

```lua
-- To access the entity, you can use the following:
local Account = _entity('Account') -- Account is alias.

Account:new({
    [AccountColumn.username] = 'test',
    [AccountColumn.password] = 'test',
    [AccountColumn.status] = AccountStatus.Active,
}):execute()
```

#### Update

```lua

Account:update({
    [AccountColumn.username] = 'test'
}):where({
    [AccountColumn.id] = 1
}):execute()
```

#### Delete

```lua
Account:delete():where({
    [AccountColumn.id] = 1
}):execute()
```

#### Select

Selecting all columns:

```lua
Account:select(SelectQuery.ALL):where({
    [AccountColumn.id] = 1
}):execute(function(result)  -- result
end)
```

Selecting specific columns:

```lua
Account:select({
    AccountColumn.id,
    AccountColumn.username,
    AccountColumn.status,
}):where({
    [AccountColumn.id] = 1
}):execute(function(result)  -- result
end)
```

Selecting with limit:

```lua
Account:select(SelectQuery.ALL):where({
    [AccountColumn.id] = 1
}):limit(1):execute(function(result)  -- result
end)
```

Selecting with order:

```lua
Account
        :select(SelectQuery.ALL)
        :orderBy(AccountColumn.username, OrderType.DESC)
        :execute(function(result)  -- result
end)
```

### IV. Caching

To cache the results, you can use the following functions:

P.S.
- The caching is not automatic, you must cache the results yourself.
- We do not recommend caching all the results, as it can be memory intensive.


```lua
Account:select(SelectQuery.ALL):execute(function(result)  -- result
    for _, row in ipairs(result) do
        Account:setCache(row.id, row)
    end
end)
```

To get the cached results:

```lua
Account:getCache(1)
Account:getCache(AccountColumn.username, 'dutchman101') -- We love you Dutchman101 :)
```

### V. Relationships

To create relationships between entities, you can use the following functions:

P.S.
- This method is uncomplete and is not recommended for use.
- If you use this method, you should not use for very large databases. (Because it is working with Join method with one query.)

```lua
AccountStatus = {
    Active = 'Active',
    Pending = 'Pending',
    Banned = 'Banned',
}

AccountColumn = {
    id = Column(TYPE.INT, { primary = true, autoIncrement = true, length = 0 }, 1),
    username = Column(TYPE.TEXT, { allowNull = true, length = 0 }, 2),
    password = Column(TYPE.VARCHAR, { allowNull = true, length = 32 }, 3),
    status = Column(enum(AccountStatus), { allowNull = true, default = AccountStatus.Pending }, 17),
    characters = OneToMany('characters', 'id', 'account_id'),
}

-- Entity('table_name', 'Alias', Column): Entity Class
Entity('accounts', 'Account', AccountColumn)
```