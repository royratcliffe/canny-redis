std = "lua54"

-- Busted globals used in spec files.
globals = {
  "describe",
  "it",
  "assert",
  "pending",
  "insulate",
  "setup",
  "teardown",
  "before_each",
  "after_each",
  "lazy_setup",
  "lazy_teardown"
}

-- Common module pattern locals in this repository.
read_globals = {
  "unpack",
  "table"
}

max_line_length = 120
unused_args = false
