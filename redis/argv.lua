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

function _M.new(...)
  return setmetatable({}, __ARGV)
end

return _M
