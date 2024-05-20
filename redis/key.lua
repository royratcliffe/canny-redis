--- Redis key sugar.
-- What to call the meta-table? If `_M` is the module table then why not `__M`?
-- Add an extra underscore prefix. Use double underscores for all meta-tables.
local __M = {}
local _M = setmetatable({}, __M)
local REDIS = require "redis"
local unpack = unpack or table.unpack

local __KEY = {}

--- Redis super-key.
-- The module-level meta-index constructs a new key, or a new array using the
-- given index and a meta-table of `__KEY`.
--
-- Does *not* answer the object itself but only its key. Use the `__call`
-- meta-method to reify the key to its database object: string, hash, set or
-- sorted set.
function __M:__index(index)
  return setmetatable({ __index = index }, __KEY)
end

--- Redis sub-key.
-- Indexing a key creates a new sub-key. The new key references the original.
-- Mutating the original (nothing prevents it) affects all its descendants.
-- @param index Sub-key.
function __KEY:__index(index)
  return setmetatable({ __indexed = self, __index = index }, __KEY)
end

--- Redis key to string.
-- Operates recursively.
--
-- Important to unpack `self`. Do not use `__index`. The following would fail
-- with stack overflow.
--
--    return self[2] and self[1] .. ":" .. self[2] or self[1]
--
function __KEY:__tostring()
  local indexed, index = rawget(self, "__indexed"), rawget(self, "__index")
  return indexed and tostring(indexed) .. ":" .. index or tostring(index)
end

--- Concatenates key to other value.
-- @param other String or other type that converts to string.
function __KEY:__concat(other)
  return tostring(self) .. tostring(other)
end

return _M
