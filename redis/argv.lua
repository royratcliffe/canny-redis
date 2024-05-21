--- Redis argument vector.
-- @module redis.argv
-- @author Roy Ratcliffe <roy@ratcliffe.me>
-- @copyright 2024
-- @license MIT
local _M = {}

local __ARGV__index = {}

local __ARGV = { __index = __ARGV__index }

function __ARGV__index:insert(key, value)
  if type(key) == "string" then
    if type(value) == "string" then
      table.insert(self, key)
      table.insert(self, value)
    elseif type(value) == "number" then
      table.insert(self, key)
      table.insert(self, tostring(value))
    elseif type(value) == "boolean" and value then
      table.insert(self, key)
    end
  end
end

function __ARGV__index:select(...)
  for index = 1, select("#", ...) do
    local arg = select(index, ...)
    if type(arg) == "table" then
      for key, value in pairs(arg) do
        self:insert(key, value)
      end
    else
      self:insert(arg, true)
    end
  end
  return self
end

--- Finds an argument's vector index.
-- @tparam string arg String argument to find.
-- @treturn ?integer Index of argument if found.
function __ARGV__index:index(arg)
  for index, value in ipairs(self) do
    if value == arg then
      return index
    end
  end
end

local __M = {}

function __M.__call(...)
  return setmetatable({}, __ARGV):select(...)
end

return setmetatable(_M, __M)
