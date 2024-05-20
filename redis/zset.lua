--- Redis sorted sets.
-- Be careful when adding packed tables. Table packing is not deterministic
-- because the order of table iteration packing works by unsorted iteration.
local _M = {}
local resp = require "resp"
local redis = require "redis"
local redis_argv = require "redis.argv"
local redis_value = require "redis.value"
local interleaved = require "interleaved"
local unpack = unpack or table.unpack

local __ZSET__index = {}

local __ZSET = { __index = __ZSET__index }

--- Scans a sorted set.
-- Answers `resp.null` for `nil` unpacked values since actual `nil` terminates
-- the iterator.
-- @param self Sorted set to scan by key.
-- @param ... Additional arguments for scan.
-- @treturn func Member iteration function.
function __ZSET:__call(...)
  local scan = { "ZSCAN", self.key, "0", unpack(redis_argv(...)) }
  return coroutine.wrap(function()
    repeat
      local members
      scan[3], members = unpack(redis.call(scan))
      for _, value, score in interleaved.ipairs(members) do
        coroutine.yield(redis_value.unpack(value) or resp.null, tonumber(score))
      end
    until scan[3] == "0"
  end)
end

--- Adds members to a sorted set.
-- Carefully construct the arguments. Optional arguments come first. Pass
-- score-value pairs at the end.
--
-- Should the members index by score or value? The index must be unique, but the
-- score does not. The `ZADD` can have more than one value with the same score.
-- This implies that the incoming members have Redis value indices with Redis
-- score values. This arrangement matches the `ZSCAN` order of iteration.
--
-- The score number must encode as a string, otherwise the Redis server raises a
-- protocol error as follows:
--
--    ERR Protocol error: expected '$', got '*'
--
function __ZSET__index:add(members, ...)
  local argv = redis_argv(...)
  for value, score in pairs(members) do
    argv:insert(score, redis_value.pack(value))
  end
  return redis.call("ZADD", self.key, unpack(argv))
end

function __ZSET__index:incrby(increment, ...)
  return redis.call("ZINCRBY", self.key, tostring(increment), redis_value.pack(...))
end

local __M = {}

function __M:__call(key, ...)
  return setmetatable({ key = key, argv = redis_argv(...) }, __ZSET)
end

return setmetatable(_M, __M)
