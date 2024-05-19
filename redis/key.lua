-- What to call the meta-table? If `_M` is the module table then why not `__M`?
-- Add an extra underscore prefix. Use double underscores for all meta-tables.
local __M = {}
local _M = setmetatable({}, __M)
local REDIS = require "redis"
local unpack = unpack or table.unpack

local __KEY = {}

-- The module-level meta-index constructs a new key, or a new array using the
-- given index and a meta-table of `__KEY`.
function __M:__index(index)
  return setmetatable({ index }, __KEY)
end

-- Indexing a key creates a new sub-key. The new key references the original.
-- Mutating the original (nothing prevents it) affects all its descendants.
function __KEY:__index(index)
  return setmetatable({ self, index }, __KEY)
end

-- Operates recursively.
--
-- Important to unpack `self`. Do not use `__index`. The following would fail
-- with stack overflow.
--
--    return self[2] and self[1] .. ":" .. self[2] or self[1]
--
function __KEY:__tostring()
  local first, second = unpack(self)
  return second and tostring(first) .. ":" .. second or first
end

function __KEY:__concat(other)
  return tostring(self) .. tostring(other)
end

return _M
