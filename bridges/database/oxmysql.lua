AM.Bridge.Register('database', 'oxmysql', {
    resource = 'oxmysql',
    query = function(sql, params) return MySQL.query.await(sql, params or {}) end,
    single = function(sql, params) return MySQL.single.await(sql, params or {}) end,
    scalar = function(sql, params) return MySQL.scalar.await(sql, params or {}) end,
    insert = function(sql, params) return MySQL.insert.await(sql, params or {}) end,
    update = function(sql, params) return MySQL.update.await(sql, params or {}) end
})
