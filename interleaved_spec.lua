describe("interleaved", function()
  local interleaving = require("interleaved")

  local collecting = {}

  --- Collects indexed pairs by iterating.
  -- @param ... Iterator parameters.
  -- @treturn tab Table of pairs.
  function collecting.ifields(...)
    local collected = {}
    for _, index, value in ... do
      if index ~= nil then collected[index] = value end
    end
    return collected
  end

  it("should iterate interleaved pairs", function()
    local interleaved = { "a", 1, "b", 2, "c", 3 }
    local collected = collecting.ifields(interleaving.ipairs(interleaved))
    assert.are.same({ a = 1, b = 2, c = 3 }, collected)
  end)

  it("should iterate interleaved pairs with nil values", function()
    local interleaved = { "a", 1, "b", nil, "c", 3 }
    local collected = collecting.ifields(interleaving.ipairs(interleaved))
    assert.are.same({ a = 1, b = nil, c = 3 }, collected)
  end)

  it("should iterate interleaved pairs with nil keys", function()
    local interleaved = { nil, 1, "b", 2, "c", 3 }
    local collected = collecting.ifields(interleaving.ipairs(interleaved))
    assert.are.same({ b = 2, c = 3 }, collected)
  end)
end)
