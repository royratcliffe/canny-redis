--- Redis call pool.
-- Performs lazy-call pooling.
-- @module redis
local _M = {}
local hi = require "hi"

--- Pools a stack of high-level Redis interfaces.
local lazycall = {}

--- Calls Redis.
-- Takes or creates a pooled Redis high-level interface, performs a single call
-- then returns the Redis interface to the pool ready for the next caller.
--
-- This only works within a co-routine threading environment. Table remove and
-- insert atomically pops and pushes from the table of high-level Redis
-- interfaces.
--
-- Creating a Redis interface throws an error if the Redis server fails to
-- connect. It reports an "host not found" error message in the log. A
-- crash dump will appear in the log and the server will continue
-- regardless.
function _M.call(...)
  local redis = table.remove(lazycall) or hi.redis()
  return (function(...)
    table.insert(lazycall, redis)
    return ...
  end)(redis(...))
end

--- Builds a colon-delimited Redis key from strings and numbers.
function _M.key(...)
  return table.concat({ ... }, ":")
end

--- Type of Redis key.
-- The answer is _always_ a string.
-- @treturn string Type of key else `none` if the key does not exist.
function _M.type(key)
  return _M.call { "TYPE", key }
end

--- Scans for keys.
-- @param ... Additional arguments for scan.
-- @treturn func Key iteration function.
function _M.scan(...)
  local args = { ... }
  return coroutine.wrap(function()
    local cursor = "0"
    repeat
      local keys
      cursor, keys = unpack(_M.call { "SCAN", cursor, unpack(args) })
      for _, key in ipairs(keys) do
        coroutine.yield(key)
      end
    until cursor == "0"
  end)
end

return _M
