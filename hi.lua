--- High-Level Redis.
-- The RESP protocol handles the wire-level connection. For typical day-to-day
-- use, however, a higher-level interface proves useful. Enter the `hi` module,
-- providing the `hi.redis` function. It constructs a Redis connection which
-- clients can call using a table or responds to `send` and `receive` methods.
-- @module hi
-- @author Roy Ratcliffe <roy@ratcliffe.me>
-- @copyright 2023, 2024
-- @license MIT
local _M = {}
local resp = require "resp"
local socket = require "socket"
require "socket.url"

local metat = {
  __index = {
    send = function(redis, ...)
      return redis.try(resp.send(redis.sock,
        select("#", ...) == 1 and ... or { ... }))
    end,
    receive = function(redis)
      return redis.try(resp.receive(redis.sock))
    end
  },
  __call = socket.protect(function(redis, ...)
    redis:send(...)
    return redis:receive()
  end)
}

--- Answers an assertion with finaliser function.
-- Creates a function that acts like `assert` but with one additional useful
-- feature: it invokes a finaliser function just before raising an error.
-- @tparam ?func finaliser Optional finaliser function.
-- @return Assertion with optional finaliser.
function _M.newtry(finaliser)
  return function(...)
    if not select(1, ...) then
      if finaliser then finaliser() end
      error(select(2, ...), 0)
    end
    return ...
  end
end

--- Creates a high-level Redis interface.
-- Close the Redis interface using the following whenever necessary; it may
-- never be necessary in practice. The connection automatically closes on error.
--
--    assert(redis.call.sock:close())
--
-- Create a temporary Redis server using Docker as follows. It pulls version
-- 7.2.4 Redis (at the time of writing) and publishes the standard Redis 6379
-- port on the local host and its RedisInsight web interface at port 8001.
--
--    docker run -p 6379:6379 -p 8001:8001 --rm redis/redis-stack
--
_M.redis = socket.protect(function(url)
  local parsedurl = assert(socket.url.parse(url
    or os.getenv("REDIS_URL")
    or "redis://localhost:6379"))
  assert(parsedurl.scheme == "redis")
  local sock = socket.tcp()
  local try = _M.newtry(function()
    sock:close()
  end)
  try(sock:connect(parsedurl.host, tonumber(parsedurl.port)))
  return setmetatable({ sock = sock, try = try }, metat)
end)

return _M
