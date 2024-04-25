describe("sorted", function()
  local sorted = require "sorted"

  it("works", function()
    local actual = {}
    for order, index, value in sorted.ipairs({
        a = 1, b = 2, c = 3, [1] = "a"
      },
      function(left, right)
        return tostring(left) < tostring(right)
      end) do
      table.insert(actual, { order, index, value })
    end
    assert.same(actual, {
      { 1, 1,   "a" },
      { 2, "a", 1 },
      { 3, "b", 2 },
      { 4, "c", 3 }
    })
  end)
end)
