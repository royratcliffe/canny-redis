local _M = {}

--- Next index, first and second values.
-- @tparam tab indexed Array of interleaved pairs.
-- @tparam index Current index.
-- @treturn number Next index.
-- @return First interleaved value.
-- @return Second interleaved value.
function _M.inext(indexed, index)
  return index + 2, indexed[index + 1], indexed[index + 2]
end

--- Iterates an interleaved array of pairs.
-- @tparam tab indexed Array of interleaved pairs.
-- @treturn func Answers the next index, first and second values.
-- @treturn tab Array of pairs to iterate.
-- @treturn number Initial iteration index of zero.
function _M.ipairs(indexed)
  return _M.inext, indexed, 0
end

return _M
