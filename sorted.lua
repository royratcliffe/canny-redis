local _M = {}

local function ordered(sorted, ordering)
  local index = sorted[1][ordering + 1]
  return index and ordering + 1, index, sorted[2][index]
end

--- Iterates pairs by sorted indices.
-- Iterates a table by first sorting its indices.
-- First collects the indices.
-- @tparam tab indexed Index-value pairs.
-- @tparam ?func comparing Index comparison function.
function _M.pairs(indexed, comparing)
  local indices = {}
  for index, _ in pairs(indexed) do
    table.insert(indices, index)
  end
  table.sort(indices, comparing)
  return ordered, { indices, indexed }, 0
end

return _M
