
function TK:HostName()
    return string.match(GetHostName(), "%[%w+%]") or "[Server]"
end

function TK:Format(num)
    if !num then return "0" end
    local int, rem = math.modf(tonumber(num))
    local val, ret, n = tostring(int), "", 0
    while true do
        ret = ret .. val[#val - n]
        n = n + 1
        if (n % 3) == 0 and n < #val then
            ret = ret..","
        end

        if n > #val then break end
    end
    if rem != 0 then
        return string.reverse(ret)..string.sub(tostring(rem), 2)
    else
        return string.reverse(ret)
    end
end

function TK:OO(num)
    if !num then return "0" end
    if num < 10 then
        return "0"..tostring(num)
    end
    return tostring(num)
end

function TK:FormatTime(num)
    if !num then return "0" end
    local days, rem = math.modf(num / 1440)
    local hours, rem = math.modf(rem * 24)
    local mins, rem = math.modf(rem * 60)
    
    if days > 0 then
        return TK:OO(days).." days "..TK:OO(hours).." hrs "..TK:OO(mins).." mins"
    elseif hours > 0 then
        return TK:OO(hours).." hrs "..TK:OO(mins).." mins"
    elseif mins > 0 then
        return TK:OO(mins).." mins"
    else
        return "0 mins"
    end
end

//--- Random string generation ---\\
local Chars = {}
for Loop = 0, 255 do
   Chars[Loop+1] = string.char(Loop)
end
local String = table.concat(Chars)

local Built = {['.'] = Chars}

local AddLookup = function(CharSet)
   local Substitute = string.gsub(String, '[^'..CharSet..']', '')
   local Lookup = {}
   for Loop = 1, string.len(Substitute) do
       Lookup[Loop] = string.sub(Substitute, Loop, Loop)
   end
   Built[CharSet] = Lookup

   return Lookup
end

function string.random(Length, CharSet)
   -- Length (number)
   -- CharSet (string, optional); e.g. %l%d for lower case letters and digits

   local CharSet = CharSet or '%a%d'

   if CharSet == '' then
      return ''
   else
      local Result = {}
      local Lookup = Built[CharSet] or AddLookup(CharSet)
      local Range = table.getn(Lookup)

      for Loop = 1,Length do
         Result[Loop] = Lookup[math.random(1, Range)]
      end

      return table.concat(Result)
   end
end

hook.Add("Initialize", "3k_Add_Hooks", function()
    GAMEMODE.EntitySpawned = function()
    end

    local Spawn = _R.Entity.Spawn
    function _R.Entity:Spawn()
        Spawn(self)
        gamemode.Call("EntitySpawned", self)
    end
end)