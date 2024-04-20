--- High-Level Redis.
-- The RESP protocol handles the wire-level connection. For typical day-to-day
-- use, however, a higher-level interface proves useful. Enter the `hi` module,
-- providing the `hi.redis` function. It constructs a Redis connection which
-- clients can call using a table or responds to `send` and `receive` methods.
-- @module hi
local _M = {}
local resp = require "resp"
local socket = require "socket"
require "LuaSocket.url"

local metat = {
  __index = {
    send = function(redis, ...)
      return redis.try(resp.send(redis.sock, ...))
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
_M.redis = socket.protect(function(url)
    local parsedurl = assert(socket.url.parse(url or os.getenv("REDIS_URL")))
    assert(parsedurl.scheme == "redis")
    local sock = socket.tcp()
    local try = _M.newtry(function()
        sock:close()
      end)
    try(sock:connect(parsedurl.host, tonumber(parsedurl.port)))
    return setmetatable({sock = sock, try = try}, metat)
  end)

return _M
