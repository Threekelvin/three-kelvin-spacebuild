
require("mysqloo")
TK.DB = TK.DB or {}
local MySQL = {}

///--- MySQL Settings ---\\\
MySQL.SQLSettings = {
    Host = "127.0.0.1",
    Port = 3306,
    Name = "threekelvin",
    Username = "gmod_dev",
    Password = "zKKZ8KSHCmx4Rzve"
}
MySQL.Placeholder = {
    ["DB_TIME"] = "UNIX_TIMESTAMP()",
    ["DB_CONN_ID"] = "CONNECTION_ID()"
}
MySQL.Schema = {}
MySQL.DataBase = nil
MySQL.ConnectionID = 0
MySQL.OSTime = 0
MySQL.Connected = false
MySQL.Running = false
MySQL.PriorityCache = {}
MySQL.Cache = {}
MySQL.NextConnect = CurTime() + 60
///--- ---\\\

function MySQL:Msg(msg)
    print(msg)
end

///--- Queries ---\\\
function MySQL:MakePriorityQuery(str, func, ...)
    table.insert(self.PriorityCache,  {str, func, {...}})
end

function MySQL:MakeQuery(str, func, ...)
    table.insert(self.Cache,  {str, func, {...}})
end

function MySQL:ProcessQuery(data)
    if !mysqloo then return false end
    if !data[1] then self:Msg("Slient Query Fail shh") return true end
    local query = self.DataBase:query(data[1])
    if !query then return false end
    
    function query:onError(msg, str)
        MySQL.Running = false
        print("-------------------")
        MySQL:Msg("Error - ".. msg)
        print("*******************")
        MySQL:Msg(str)
        print("-------------------")
        
        if msg == "MySQL server has gone away" then
            MySQL.Connected = false
            print("fail?")
            pcall(MySQL.MakePriorityQuery, MySQL, data[1], data[2], unpack(data[3]))
        end
        
        data = nil
        self = nil
    end
    
    function query:onSuccess(rdata)
        MySQL.Running = false
        if data[2] then
            pcall(data[2], rdata, unpack(data[3]))
        end
        
        data = nil
        self = nil
    end
    
    query:start()
    self.Running = true
    return true
end
///--- ---\\\

///--- Setup ---\\\
function MySQL:Setup()
    self:MakePriorityQuery("SELECT CONNECTION_ID()", function(Data)
        MySQL.ConnectionID = tonumber(Data[1]["CONNECTION_ID()"])
    end)

    for k,v in pairs(self:GetCreateQueries()) do
        self:MakePriorityQuery(v)
    end
end

function MySQL:Connect()
    if !mysqloo then return end
    print("-------------------")
    print("mysqloo Connecting")
    print("-------------------")
    self.Schema = list.Get("TK_Database")
    self.DataBase = mysqloo.connect(self.SQLSettings.Host, self.SQLSettings.Username, self.SQLSettings.Password, self.SQLSettings.Name, self.SQLSettings.Port)
    self.DataBase:connect()
    
    self.DataBase.onConnected = function()
        print("-------------------")
        MySQL:Msg("Database Connected")
        print("-------------------")
        
        if !MySQL.Connected then
            MySQL.Connected = true
        end
        
        MySQL:Setup()
    end
    
    self.DataBase.onConnectionFailed = function(db, msg)
        print("-------------------")
        MySQL:Msg(msg)
        print("-------------------")
    end
end


///--- Hooks ---\\\
hook.Add("Initialize", "MySQLLoad", function()
    MySQL:Connect()
end)

hook.Add("OnReloaded", "MySQLLoad", function()
    MySQL:Connect()
end)

hook.Add("Tick", "MySQLQuery", function()
    if !mysqloo then return end
    if MySQL.Running or (#MySQL.PriorityCache == 0 and #MySQL.Cache == 0) then return end
    
    if MySQL.Connected then
        if #MySQL.PriorityCache != 0 then
            local query = MySQL.PriorityCache[1]
            if MySQL:ProcessQuery(query) then
                table.remove(MySQL.PriorityCache, 1)
            else
                MySQL.Connected = false
            end
        elseif #MySQL.Cache != 0 then
            local query = MySQL.Cache[1]
            if MySQL:ProcessQuery(query) then
                table.remove(MySQL.Cache, 1)
            else
                MySQL.Connected = false
            end
        else
            MySQL:Msg("Query System Error")
        end
    elseif CurTime() >= MySQL.NextConnect then
        MySQL.NextConnect = CurTime() + 60
        local status = MySQL.DataBase:status()
        if status == 0 then
            MySQL.Connected = true
        elseif status != 1 then
            MySQL.DataBase:connect()
        end
    end
end)
///--- ---\\\


///--- Conversions ---\\\
function MySQL:GmodToDatabase(dbtable, idx, value)
    if !self.Schema[dbtable] then return value end
    if !self.Schema[dbtable][idx] then return value end
    
    if self.Schema[dbtable][idx].p_h then
        for k,v in pairs(MySQL.Placeholder) do
            if value != k then continue end
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
    if !self.Schema[dbtable] then return value end
    if !self.Schema[dbtable][idx] then return value end
    
    if self.Schema[dbtable][idx].type == "table" then
        return util.JSONToTable(value)
    elseif self.Schema[dbtable][idx].type == "boolean" then
        return value == 1
    elseif self.Schema[dbtable][idx].type == "number" then
        return tonumber(value)
    end
    
    return tostring(value)
end
///--- ---\\\

///--- Query Setup ---\\\
function MySQL:GetCreateQueries()
    local query_list = {}
    for dbtable,data in pairs(self.Schema) do
        local query = {"CREATE TABLE IF NOT EXISTS", dbtable, "("}
        for idx,val in pairs(data) do
            table.insert(query, idx)
            for _,value in ipairs(val) do
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
    if !self.Schema[dbtable] then return end
    
    local query = {"INSERT IGNORE INTO ", dbtable, " SET "}
    for idx,val in pairs(values) do
        table.insert(query, SQLStr(idx, true) .." = ".. self:GmodToDatabase(dbtable, idx, val))
        table.insert(query, ", ")
    end

    query[#query] = nil
    return table.concat(query, "")
end

function MySQL:FormatSelectQuery(dbtable, values, where, order, limit)
    if !self.Schema[dbtable] then return end

    local query = {"SELECT "}
    values = (!values or table.Count(values) == 0) and {"*"} or values
    for _,val in pairs(values) do
        table.insert(query, SQLStr(val, true))
        table.insert(query, ", ")
    end
    
    query[#query] = " FROM ".. dbtable .."  WHERE "
    for k,v in pairs(where) do
        table.insert(query, string.format(SQLStr(k, true), SQLStr(v, type(v) == "number")))
        table.insert(query, " AND ")
    end
    
    if order then
        query[#query] = " ORDER BY "
        local desc = false
        for k,v in pairs(order) do
            if v == "DESC" then desc = true continue end
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
    if !self.Schema[dbtable] then return end
    
    local query = {"UPDATE ", dbtable, " SET "}
    for idx,val in pairs(values) do
        table.insert(query, SQLStr(idx, true) .." = ".. self:GmodToDatabase(dbtable, idx, val))
        table.insert(query, ", ")
    end
    
    query[#query] = " WHERE "
    for k,v in pairs(where) do
        table.insert(query, string.format(SQLStr(k, true), SQLStr(v, type(v) == "number")))
        table.insert(query, " AND ")
    end
    
    query[#query] = " LIMIT 1"
    return table.concat(query, "")
end
///--- ---\\\


///--- Functions ---\\\
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
        for k,v in pairs(data) do
            for idx,val in pairs(v) do
                data[k][idx] = MySQL:DatabaseToGmod(dbtable, idx, val)
            end
        end
        
        pcall(callback, data, unpack({...}))
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
///--- ---\\\