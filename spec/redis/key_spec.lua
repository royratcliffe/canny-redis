describe("redis.key", function()
    local REDIS_KEY = require "redis.key"

    it("works", function()
        local key = REDIS_KEY.hello["world"]
        assert.are.same({ { "hello" }, "world" }, key)
        assert.are.equal("hello:world", tostring(key))
        assert.are.equal("prefix_hello:world", "prefix_" .. key)
        assert.are.equal("hello:world_suffix", key .. "_suffix")
    end)
end)
