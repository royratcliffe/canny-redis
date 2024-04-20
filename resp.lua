local _M = {
  null = {}
}

-- Asserts only if the first return value is nil, not if `false`.
function _M.assert(...)
  if select(1, ...) == nil then
    error(select(2, ...), 0)
  end
  return ...
end

function _M.send(sock, data)
  return _M[assert("send"..type(data))](sock, data)
end

function _M.sendnumber(sock, data)
  return sock:send(":"..data.."\r\n")
end

function _M.sendstring(sock, data)
  return sock:send("$"..#data.."\r\n"..data.."\r\n")
end

function _M.sendtable(sock, data)
  local sent = _M.assert(sock:send("*"..#data.."\r\n"))
  for _, item in ipairs(data) do
    sent = sent + _M.assert(_M.send(sock, item))
  end
  return sent
end

local receive = {
  ["-"] = function(sock, rest)
    return false, rest
  end,
  ["+"] = function(sock, rest)
    return rest
  end,
  [":"] = function(sock, rest)
    return tonumber(rest)
  end,
  ["$"] = function(sock, rest)
    local len = tonumber(rest)
    if len == -1 then return _M.null end
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

function _M.receive(sock)
  local data = _M.assert(sock:receive("*l"))
  return _M.assert(receive[data:sub(1, 1)])(sock, data:sub(2))
end

return _M
