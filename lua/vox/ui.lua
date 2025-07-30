local M = {}
local config = require('vox.config')

local win_id = nil
local buf_id = nil
local timer_id = nil

local function create_floating_window(width, height, title)
  -- Create buffer
  buf_id = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf_id, 'bufhidden', 'wipe')

  -- Calculate window position (bottom-right corner)
  local ui = vim.api.nvim_list_uis()[1]
  local row = ui.height - height - 2
  local col = ui.width - width - 2

  -- Window options
  local opts = {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = title,
    title_pos = 'center'
  }

  -- Create window
  win_id = vim.api.nvim_open_win(buf_id, false, opts)

  return buf_id, win_id
end

local function close_floating_window()
  if timer_id then
    vim.fn.timer_stop(timer_id)
    timer_id = nil
  end

  if win_id and vim.api.nvim_win_is_valid(win_id) then
    vim.api.nvim_win_close(win_id, true)
  end

  win_id = nil
  buf_id = nil
  start_time = nil
end

local function format_duration(seconds)
  return string.format('%02d:%02d', math.floor(seconds / 60), seconds % 60)
end

function M.show_recording_window()
  if not config.get().show_floating_window then
    return
  end

  close_floating_window()

  local width = 30
  local height = 1
  local buf, win = create_floating_window(width, height, '')

  -- Show recording message
  local content = '🔴 Recording... (press to stop)'
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { content })

  -- Set highlight for recording state
  vim.api.nvim_win_set_option(win, 'winhl', 'Normal:ErrorFloat')

  -- Make buffer content red and bold
  vim.api.nvim_buf_add_highlight(buf, -1, 'ErrorMsg', 0, 0, -1)
end

function M.show_transcribing_window()
  if not config.get().show_floating_window then
    return
  end

  close_floating_window()

  local width = 20
  local height = 1
  local buf, win = create_floating_window(width, height, '')

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { '� Transcribing...' })
  vim.api.nvim_win_set_option(win, 'winhl', 'Normal:WarningFloat')
end

function M.show_success_window()
  if not config.get().show_floating_window then
    return
  end

  close_floating_window()

  local width = 15
  local height = 1
  local buf, win = create_floating_window(width, height, '')

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { ' Text inserted' })
  vim.api.nvim_win_set_option(win, 'winhl', 'Normal:DiagnosticOk')

  -- Auto-close after 2 seconds
  vim.defer_fn(function()
    close_floating_window()
  end, 2000)
end

function M.show_error_window(error_msg)
  if not config.get().show_floating_window then
    vim.notify(error_msg, vim.log.levels.ERROR)
    return
  end

  close_floating_window()

  local width = math.min(50, #error_msg + 4)
  local height = 1
  local buf, win = create_floating_window(width, height, '')

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { 'L ' .. error_msg })
  vim.api.nvim_win_set_option(win, 'winhl', 'Normal:ErrorFloat')

  -- Keep error visible for longer
  vim.defer_fn(function()
    close_floating_window()
  end, 5000)
end

function M.close()
  close_floating_window()
end

return M

