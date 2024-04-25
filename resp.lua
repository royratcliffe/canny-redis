--- Redis Wire Protocol.
-- The Redis database communicates with its clients using RESP. The RESP wire
-- protocol runs over a bidirectional TCP connection---octets in, octets out.
--
-- The wire protocol itself is very simple---a line-based synchronous
-- send-receive cycle where the connection client sends a command and then
-- receives its reply. All Redis commands work that way, even if the reply is an
-- "OK" status or error. Only one exception to this pattern occurs: Subscribing
-- to a broadcast channel alters the protocol to a continuous receive cycle.
-- Simple.
-- @module resp
-- @author Roy Ratcliffe <roy@ratcliffe.me>
-- @copyright 2023, 2024
-- @license MIT
local _M = {
  null = {}
}

--- Raises error if `nil`.
-- The `resp` module provides its own version of `assert`. It exists in order to
-- trigger errors _without_ stack information about where the error occurs. It
-- errors with a level of `0` as the second argument meaning "send the error
-- message only," that is, without the stack traceback.
--
-- Asserts only if the first return value is `nil`, not if `false`. Returns all
-- arguments, including the first, if the first argument does not compare equal
-- to `nil`.
--
-- @param ... Arguments where the first asserts as non-`nil` and the second
-- supplies the error message if `nil`.
-- @return All arguments if no error.
function _M.assert(...)
  if select(1, ...) == nil then
    error(select(2, ...), 0)
  end
  return ...
end

--- Sends data according to type to a Redis server.
-- @param sock Socket to use for sending.
-- @param data Data to send.
function _M.send(sock, data)
  return _M[assert("send" .. type(data))](sock, data)
end

--- Sends a number to a Redis server.
-- @param sock Socket to use for sending.
-- @tparam number data Number to send.
function _M.sendnumber(sock, data)
  return sock:send(":" .. data .. "\r\n")
end

--- Sends a bulk string to a Redis server.
-- @param sock Socket to use for sending.
-- @tparam string data String to send.
function _M.sendstring(sock, data)
  return sock:send("$" .. #data .. "\r\n" .. data .. "\r\n")
end

--- Sends an array to a Redis server.
-- @param sock Socket to use for sending.
-- @tparam tab data Array to send.
function _M.sendtable(sock, data)
  local sent = _M.assert(sock:send("*" .. #data .. "\r\n"))
  for _, item in ipairs(data) do
    sent = sent + _M.assert(_M.send(sock, item))
  end
  return sent
end

local receive = {
  ["-"] = function(_, rest)
    return false, rest
  end,
  ["+"] = function(_, rest)
    return rest
  end,
  [":"] = function(_, rest)
    return tonumber(rest)
  end,
  ["$"] = function(sock, rest)
    local len = tonumber(rest)
    if len < 0 then return _M.null end
    local data = _M.assert(sock:receive(len))
    _M.assert(sock:receive("*l") == "")
    return data
  end,
  ["*"] = function(sock, rest)
    local len = tonumber(rest)
    local data = {}
    for index = 1, len do
      local item = _M.assert(_M.receive(sock))
      data[index] = item
    end
    return data
  end
}

--- Receives data from a Redis server.
-- The data has one of types. The initial character determines the type.
-- * Error
-- * Simple string
-- * Number, integer or floating-point
-- * Bulk string
-- * Null encoded as a bulk string of length -1
-- * Array of items
function _M.receive(sock)
  local data = _M.assert(sock:receive("*l"))
  return _M.assert(receive[data:sub(1, 1)])(sock, data:sub(2))
end

return _M
