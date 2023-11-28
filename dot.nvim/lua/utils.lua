local fn = vim.fn

local Utils = {}
Utils.__index = Utils

function Utils.executable(name)
  if fn.executable(name) > 0 then
    return true
  end

  return false
end

--- check whether a feature exists in Nvim
--- @feat: string
---   the feature name, like `nvim-0.7` or `unix`.
--- return: bool
Utils.has = function(feat)
  if fn.has(feat) == 1 then
    return true
  end

  return false
end

--- Create a dir if it does not exist
function Utils.may_create_dir(dir)
  local res = fn.isdirectory(dir)

  if res == 0 then
    fn.mkdir(dir, "p")
  end
end

function Utils:insert_text(text)
    local row, col = unpack(api.nvim_win_get_cursor(0))
    api.nvim_buf_set_text(0, row, col, row, col, { text })
end

return Utils
