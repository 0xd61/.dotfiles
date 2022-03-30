local syntax = require "core.syntax"

syntax.add {
  files = { "todo.*%.txt$" },
  patterns = {
    { pattern = "x%s.-\n",          type = "comment"  },
    { pattern = "(%d+%-%d+%-%d+)",  type = "number"   },
    { pattern = "%([A-Z]%)%s",      type = "literal"  },
    { pattern = "%s%+[%w]*",        type = "keyword2" },
    { pattern = "%s@[%w]*",         type = "keyword"  },
    { pattern = "%s#[%w]*",         type = "symbol"   },
    { pattern = "[%w]*:[%w_%-]*",   type = "string"   },
  },
  symbols = {
  },
}

