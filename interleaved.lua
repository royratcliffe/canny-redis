--- Interleaved pairs.
-- @module interleaved
-- @author Roy Ratcliffe <roy@ratcliffe.me>
-- @copyright 2023, 2024
-- @license MIT
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

--- Undoes interleaved field and value pairs.
-- Collating the interleaved pairs throws away the order of the fields. The
-- fields become key-value pairs within a Lua table without prescribed key
-- ordering and without `nil` values; assigning `nil` to a key removes it.
--
-- @tparam tab interleaved An array of interleaved field values.
-- @tparam ?tab fields Optional table of fields.
-- @treturn tab Table of field-value pairs, unordered.
function _M.undo(interleaved, fields)
  fields = fields or {}
  for index = 1, #interleaved - 1, 2 do
    fields[interleaved[index]] = interleaved[index + 1]
  end
  return fields
end

--- Redoes field interleaving.
-- This has limited utility when ordering matters. Lua cannot guarantee the
-- order of the interleaved field pairs. Value always follows the field but the
-- order of each pair depends on Lua's unsorted presentation of pairs. When
-- order does matter, apply order-critical pairs separately.
-- @tparam tab fields Table of fields.
-- @tparam ?tab interleaved Optional array of interleaved field values.
-- @treturn tab Interleaved array of field-value pairs, unordered.
function _M.redo(fields, interleaved)
  interleaved = interleaved or {}
  for field, value in pairs(fields) do
    table.insert(interleaved, field)
    table.insert(interleaved, value)
  end
  return interleaved
end

return _M
