--- Sorted pairs.
-- @module sorted
-- @author Roy Ratcliffe <roy@ratcliffe.me>
-- @copyright 2023, 2024
-- @license MIT
local _M = {}

-- Iterates an ordering of values by their sorted indices.
-- @tparam tab sorted Sorted indices and indexed values.
-- @tparam int ordering Current ordering index.
local function ordered(sorted, ordering)
  local index = sorted[1][ordering + 1]
  return index and ordering + 1, index, sorted[2][index]
end

--- Iterates pairs by sorted indices.
-- Iterates a table by first sorting its indices.
-- First collects the indices.
-- Then sorts them using the optional comparison function.
-- Finally, iterates the sorted indices and their corresponding values.
-- @tparam tab indexed Index-value pairs.
-- @tparam ?func comparing Index comparison function.
function _M.ipairs(indexed, comparing)
  local indices = {}
  for index, _ in pairs(indexed) do
    table.insert(indices, index)
  end
  table.sort(indices, comparing)
  return ordered, { indices, indexed }, 0
end

return _M
