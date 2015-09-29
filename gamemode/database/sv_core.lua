require("tmysql4")
TK.DB = TK.DB or {}
local MySQL = {}

--/--- MySQL Settings ---\\\
MySQL.SQLSettings = {
    Host = "127.0.0.1",
    Port = 3306,
    Name = "three_kelvin",
    Username = "root",
    Password = "qwerty"
}

MySQL.Placeholder = {
    ["DB_TIME"] = "UNIX_TIMESTAMP()",
    ["DB_CONN_ID"] = "CONNECTION_ID()"
}

MySQL.Schema = {}
MySQL.Database = nil
MySQL.ConnectionID = 0
MySQL.OSTime = 0
MySQL.Connected = false
MySQL.Running = false
MySQL.PriorityCache = {}
MySQL.Cache = {}
MySQL.NextConnect = CurTime() + 60

--/--- ---\\\
--/--- Queries ---\\\
function MySQL:MakePriorityQuery(str, func, ...)
    local data = {}
    data.query = str
    data.callback = func
    data.args = {...}
    table.insert(self.PriorityCache, data)
end

function MySQL:MakeQuery(str, func, ...)
    local data = {}
    data.query = str
    data.callback = func
    data.args = {...}
    table.insert(self.Cache, data)
end

function MySQL.Callback(qdata, results)
    if results[1].status then
        if qdata.callback then
            local valid, info = pcall(qdata.callback, results[1].data, unpack(qdata.args))

            if not valid then
                print(info)
            end
        end
    else
        print("-------------------")
        print("Error    - " .. results[1].error or "")
        print("Error id - " .. results[1].errorid or "")
        print("-------------------")
        MySQL:MakePriorityQuery(qdata.query, qdata.callback, unpack(qdata.args))
        MySQL.Connected = false
        MySQL.NextConnect = CurTime() + 60
    end

    qdata = nil
    results = nil
    MySQL.Running = false
end

function MySQL:ProcessQuery(qdata)
    if not tmysql then return end
    self.Database:Query(qdata.query, MySQL.Callback, 1, qdata)
    MySQL.Running = true
end

--/--- ---\\\
--/--- Setup ---\\\
function MySQL:Setup()
    self.Schema = list.Get("TK_Database")

    self:MakePriorityQuery("SELECT CONNECTION_ID()", function(Data)
        MySQL.ConnectionID = tonumber(Data[1]["CONNECTION_ID()"])
    end)

    for k, v in pairs(self:GetCreateQueries()) do
        self:MakePriorityQuery(v)
    end
end

function MySQL:Connect()
    if not tmysql then return end
    print("-------------------")
    print("tmysql Connecting")
    print("-------------------")
    local database, error_string = tmysql.initialize(self.SQLSettings.Host, self.SQLSettings.Username, self.SQLSettings.Password, self.SQLSettings.Name, self.SQLSettings.Port)
    self.Database = database

    if not database then
        print("-------------------")
        print(error_string)
        print("-------------------")
    else
        print("-------------------")
        print("Database Connected")
        print("-------------------")
        self.Connected = true
        self.Running = false
        self:Setup()
    end
end

--/--- Hooks ---\\\
hook.Add("Initialize", "MySQLLoad", function()
    MySQL:Connect()
end)

hook.Add("OnReloaded", "MySQLLoad", function()
    MySQL:Connect()
end)

hook.Add("Tick", "MySQLQuery", function()
    if not tmysql then return end
    if MySQL.Running then return end
    local pcache_count = #MySQL.PriorityCache
    local cache_count = #MySQL.Cache
    if pcache_count == 0 and cache_count == 0 then return end

    if MySQL.Connected then
        if pcache_count ~= 0 then
            MySQL:ProcessQuery(MySQL.PriorityCache[1])
            table.remove(MySQL.PriorityCache, 1)
        elseif cache_count ~= 0 then
            MySQL:ProcessQuery(MySQL.Cache[1])
            table.remove(MySQL.Cache, 1)
        else
            print("Query System Error")
        end
    elseif CurTime() >= MySQL.NextConnect then
        MySQL.NextConnect = CurTime() + 60

        if not MySQL.Database then
            MySQL:Connect()
        else
            MySQL.Database:Query("SELECT CONNECTION_ID()", function(results)
                if results[1].status then
                    MySQL.Connected = true
                    MySQL.Running = false
                    MySQL.ConnectionID = tonumber(results[1].data["CONNECTION_ID()"])
                    print("-------------------")
                    print("Database Connected")
                    print("-------------------")
                end
            end, 1)
        end

        MySQL.Running = true
    end
end)

--/--- ---\\\
--/--- Conversions ---\\\
function MySQL:GmodToDatabase(dbtable, idx, value)
    if not self.Schema[dbtable] then return value end
    if not self.Schema[dbtable][idx] then return value end

    if self.Schema[dbtable][idx].p_h then
        for k, v in pairs(MySQL.Placeholder) do
            if value ~= k then continue end

            return v
        end
    elseif self.Schema[dbtable][idx].type == "table" then
        return SQLStr(util.TableToJSON(value))
    elseif self.Schema[dbtable][idx].type == "boolean" then
        return SQLStr(value and 1 or 0, true)
    elseif self.Schema[dbtable][idx].type == "number" then
        return SQLStr(tonumber(value), true)
    end

    return SQLStr(value)
end

function MySQL:DatabaseToGmod(dbtable, idx, value)
    if not self.Schema[dbtable] then return value end
    if not self.Schema[dbtable][idx] then return value end

    if self.Schema[dbtable][idx].type == "table" then
        return util.JSONToTable(value)
    elseif self.Schema[dbtable][idx].type == "boolean" then
        return value == 1
    elseif self.Schema[dbtable][idx].type == "number" then
        return tonumber(value)
    end

    return tostring(value)
end

--/--- ---\\\
--/--- Query Setup ---\\\
function MySQL:GetCreateQueries()
    local query_list = {}

    for dbtable, data in pairs(self.Schema) do
        local query = {"CREATE TABLE IF NOT EXISTS",  dbtable,  "("}

        for idx, val in pairs(data) do
            table.insert(query, idx)

            for _, value in ipairs(val) do
                table.insert(query, value)
            end

            table.insert(query, ",")
        end

        query[#query] = ")"
        table.insert(query_list, table.concat(query, " "))
    end

    return query_list
end

function MySQL:FormatInsertQuery(dbtable, values)
    if not self.Schema[dbtable] then return end
    local query = {"INSERT IGNORE INTO ",  dbtable,  " SET "}

    for idx, val in pairs(values) do
        table.insert(query, SQLStr(idx, true) .. " = " .. self:GmodToDatabase(dbtable, idx, val))
        table.insert(query, ", ")
    end

    query[#query] = nil

    return table.concat(query, "")
end

function MySQL:FormatSelectQuery(dbtable, values, where, order, limit)
    if not self.Schema[dbtable] then return end
    local query = {"SELECT "}
    values = (not values or table.Count(values) == 0) and {"*"} or values

    for _, val in pairs(values) do
        table.insert(query, SQLStr(val, true))
        table.insert(query, ", ")
    end

    query[#query] = " FROM " .. dbtable .. "  WHERE "

    for k, v in pairs(where) do
        table.insert(query, string.format(SQLStr(k, true), SQLStr(v, type(v) == "number")))
        table.insert(query, " AND ")
    end

    if order then
        query[#query] = " ORDER BY "
        local desc = false

        for k, v in pairs(order) do
            if v == "DESC" then
                desc = true
                continue
            end

            table.insert(query, SQLStr(v, true))
            table.insert(query, ", ")
        end

        if desc then
            query[#query] = " DESC"
            table.insert(query, " ")
        end
    end

    if limit then
        query[#query] = " LIMIT "
        table.insert(query, SQLStr(tonumber(limit), true))
        table.insert(query, " ")
    end

    query[#query] = nil

    return table.concat(query, "")
end

function MySQL:FormatUpdateQuery(dbtable, values, where)
    if not self.Schema[dbtable] then return end
    local query = {"UPDATE ",  dbtable,  " SET "}

    for idx, val in pairs(values) do
        table.insert(query, SQLStr(idx, true) .. " = " .. self:GmodToDatabase(dbtable, idx, val))
        table.insert(query, ", ")
    end

    query[#query] = " WHERE "

    for k, v in pairs(where) do
        table.insert(query, string.format(SQLStr(k, true), SQLStr(v, type(v) == "number")))
        table.insert(query, " AND ")
    end

    query[#query] = " LIMIT 1"

    return table.concat(query, "")
end

--/--- ---\\\
--/--- Functions ---\\\
function TK.DB:IsConnected()
    return tobool(MySQL.Connected)
end

function TK.DB:ConnectionID()
    return MySQL.ConnectionID
end

function TK.DB:InsertQuery(dbtable, values)
    MySQL:MakeQuery(MySQL:FormatInsertQuery(dbtable, values))
end

function TK.DB:SelectQuery(dbtable, values, where, order, limit, callback, ...)
    MySQL:MakePriorityQuery(MySQL:FormatSelectQuery(dbtable, values, where, order, limit), function(data, ...)
        for k, v in pairs(data) do
            for idx, val in pairs(v) do
                data[k][idx] = MySQL:DatabaseToGmod(dbtable, idx, val)
            end
        end

        local valid, info = pcall(callback, data, unpack({...}))

        if not valid then
            print(info)
        end
    end, unpack({...}))
end

function TK.DB:UpdateQuery(dbtable, values, where)
    MySQL:MakeQuery(MySQL:FormatUpdateQuery(dbtable, values, where))
end

function TK.DB:GmodToDatabase(dbtable, idx, value)
    return MySQL:GmodToDatabase(dbtable, idx, value)
end

function TK.DB:DatabaseToGmod(dbtable, idx, value)
    return MySQL:DatabaseToGmod(dbtable, idx, value)
end
--/--- ---\\\
