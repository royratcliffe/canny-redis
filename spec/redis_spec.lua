describe("redis", function()
  local redis = require "redis"

  it("works", function()
    local lolwut = redis.call { "LOLWUT", "VERSION", tostring(7) }
    assert.are.equal(lolwut, redis.call("LOLWUT", "VERSION", tostring(7)))
  end)

  describe("scan", function()
    local key = "key"

    before_each(function()
      redis.call("DEL", key)
    end)

    after_each(function()
      redis.call("EXPIRE", key, tostring(30))
    end)

    it("hash", function()
      redis.call("HSET", key, "field", "value")
      local actual = {}
      for field, value in redis.hscan(key) do
        table.insert(actual, { field, value })
      end
      assert.are.same({ { "field", "value" } }, actual)
    end)

    it("hash without values", function()
      redis.call("HSET", key, "field", "value")
      assert.has_error(function()
        redis.hscan("key", { NOVALUES = true })()
      end, "ERR syntax error")
    end)

    it("unordered set", function()
      redis.call("SADD", key, "c", "b", "a", "a")
      local actual = {}
      for member in redis.sscan(key, { MATCH = "*", COUNT = 1 }) do
        table.insert(actual, member)
      end
      table.sort(actual)
      assert.are.same({ "a", "b", "c" }, actual)
    end)

    it("ordered set", function()
      redis.call("ZADD", key, tostring(100), "value")
      local actual = {}
      for member, score in redis.zscan(key) do
        table.insert(actual, { member, score })
      end
      assert.are.same({ { "value", 100 } }, actual)
    end)
  end)
end)
