package = "canny-redis"
version = "0.1-0"
source = {
  url = "https://github.com/royratcliffe/canny-redis.git",
  tag = "main"
}
description = {
  summary = "Redis Wire Protocol in Lua",
  detailed = [[
    The Redis database communicates with its clients using RESP. The RESP wire protocol runs over a bidirectional TCP connection---octets in, octets out.

    The wire protocol itself is very simple---a line-based synchronous send-receive cycle where the connection client sends a command and then receives its reply. Subscribing to a broadcast channel alters the protocol to a continuous receive cycle. Simple.
  ]],
  homepage = "https://github.com/royratcliffe/canny-redis",
  license = "MIT"
}
dependencies = {
  "lua >= 5.1"
}
build = {
  type = "builtin"
}
