describe("redis.key", function()
  local REDIS_KEY = require "redis.key"

  it("hello[1].worlds", function()
    local key = REDIS_KEY.hello[1].worlds
    assert.are.same({
      __indexed = {
        __indexed = {
          __index = "hello" },
        __index = 1
      },
      __index = "worlds"
    }, key)
    assert.are.equal("hello:1:worlds", tostring(key))
    assert.are.equal("prefix_hello:1:worlds", "prefix_" .. key)
    assert.are.equal("hello:1:worlds_suffix", key .. "_suffix")
  end)

  it("REDIS_KEY[1]", function()
    assert.are.equal("1", tostring(REDIS_KEY[1]))
  end)
end)
