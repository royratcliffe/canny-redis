describe("hi", function()
  local hi = require "hi"

  it("works", function()
    assert.not_nil(hi.redis("redis://localhost:6379"))
  end)
end)
