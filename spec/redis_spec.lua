describe("redis", function()
  local redis = require "redis"

  it("works", function()
    local lolwut = redis.call { "LOLWUT", "VERSION", tostring(7) }
    assert.are.equal(lolwut, redis.call("LOLWUT", "VERSION", tostring(7)))
  end)
end)
