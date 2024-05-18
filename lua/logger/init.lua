local function remove_duplicate_whitespace(str)
  return str:gsub('%s+', ' ')
end

local function is_white_space(str)
  return str:gsub('%s', '') == ''
end

local function split(str, sep)
  if sep == nil then
    sep = '%s'
  end
  local t = {}
  for s in string.gmatch(str, '([^' .. sep .. ']+)') do
    table.insert(t, s)
  end
  return t
end

local function trim(str)
  return str:gsub('^%s+', ''):gsub('%s+$', '')
end

---@class logger
---@field lines string[]
---@field max_lines number
---@field enabled boolean not used yet, but if we get reports of slow, we will use this
local M = {}

M.__index = M

---@return logger
function M:new()
  local logger = setmetatable({
    lines = {},
    enabled = true,
    max_lines = 1000,
    liveupdate = true,
    bufnr = nil, -- Add buffer number for log window
    winnr = nil, -- Add window ID for log window
    open = false,
  }, self)

  return logger
end

---@vararg any
function M:log(...)
  local processed = {}
  for i = 1, select('#', ...) do
    local item = select(i, ...)
    if type(item) == 'table' then
      item = vim.inspect(item)
    end
    if type(item) == 'boolean' then
      item = tostring(item)
    end
    table.insert(processed, item)
  end

  local lines = {}
  for _, line in ipairs(processed) do
    local _split = split(line, '\n')
    for _, l in ipairs(_split) do
      if not is_white_space(l) then
        local ll = trim(remove_duplicate_whitespace(l))
        table.insert(lines, ll)
      end
    end
  end

  table.insert(self.lines, table.concat(lines, ' '))

  while #self.lines > self.max_lines do
    table.remove(self.lines, 1)
  end

  if self.enabled and self.bufnr and vim.api.nvim_buf_is_loaded(self.bufnr) then
    vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, self.lines)
  end
end

function M:clear()
  self.lines = {}
end

function M:create_buf()
  self.bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(self.bufnr, 'logger')
  vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, self.lines)
  self:log('Logger started...')
  self:log()
  self:log()
end

function M:toggle()
  if self.winnr == nil or not vim.api.nvim_win_is_valid(self.winnr) then
    self.winner = nil
  end

  if not self.bufnr then
    self:create_buf()
  end

  if self.open then
    vim.api.nvim_win_close(self.winnr, true)
    self.open = false
    return
  end

  local current_win = vim.api.nvim_get_current_win()
  vim.cmd([[
      vsplit
      vertical resize 80
    ]])
  self.winnr = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(self.winnr, self.bufnr)
  vim.bo[self.bufnr].ft = 'logger'
  vim.api.nvim_set_current_win(current_win)
  self.open = true
end

--- @class LoggerConfig
--- @field show_on_start boolean

---@param config LoggerConfig
function M:setup(config)
  if config.show_on_start then
    vim.defer_fn(function()
      require('logger'):toggle()
    end, 200)
  end
end

return M:new()
