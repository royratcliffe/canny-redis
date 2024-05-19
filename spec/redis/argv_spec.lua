describe("redis.argv", function()
  local redis_argv = require "redis.argv"

  it("works", function()
    local argv = redis_argv.new()
    assert.are.same({}, argv)
    argv:select { HELLO = true }
    assert.are.same({ "HELLO" }, argv)
    argv:select { WORLD = 123.456 }
    assert.are.same({ "HELLO", "WORLD", "123.456" }, argv)
  end)
end)
