AM.Database = AM.Database or {}
function AM.Database.Query(q,p) return MySQL.query.await(q,p or {}) end
function AM.Database.Single(q,p) return MySQL.single.await(q,p or {}) end
function AM.Database.Scalar(q,p) return MySQL.scalar.await(q,p or {}) end
function AM.Database.Insert(q,p) return MySQL.insert.await(q,p or {}) end
function AM.Database.Update(q,p) return MySQL.update.await(q,p or {}) end
function AM.Database.Transaction(queries,params) return MySQL.transaction.await(queries,params) end
