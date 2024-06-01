--[[
    * Inception Game
    * This example is a simple entity that represents an account.
]]--

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

Entity('accounts', 'Account', AccountColumn)
