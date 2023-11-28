vim.loader.enable() -- use updated loader

vim.opt.termguicolors = true
vim.cmd("colorscheme dgl")

local core_conf_files = {
  "globals.lua", -- some global settings
  "options.vim", -- setting options in nvim
  -- "autocommands.vim", -- various autocommands
  "plugins.lua", -- all the plugins installed and their configurations
  "keymaps.lua", -- all the user-defined mappings
  "commands.lua", -- custom commands
  "snippets.lua", -- luasnip snippets
  -- "colorschemes.lua", -- colorscheme settings
}

local vim_conf_dir = vim.fn.stdpath("config").."/vim"
-- source all the core config files
for _, file_name in ipairs(core_conf_files) do
  if vim.endswith(file_name, 'vim') then
    local path = string.format("%s/%s", vim_conf_dir, file_name)
    local source_cmd = "source " .. path
    vim.cmd(source_cmd)
  else
    local module_name, _ = string.gsub(file_name, "%.lua", "")
    package.loaded[module_name] = nil
    require(module_name)
  end
end

local proj_conf_files = {
    ".project.vim",
    ".project.lua",
}

-- source all the core config files
for _, file_name in ipairs(proj_conf_files) do
  if io.open(file_name) then
    if vim.endswith(file_name, 'vim') then
      local source_cmd = "source " .. file_name
      vim.cmd(source_cmd)
    else
      local module_name, _ = string.gsub(file_name, "%.lua", "")
      package.loaded[module_name] = nil
      require(module_name)
    end
  end
end
