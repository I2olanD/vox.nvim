local M = {}
local config = require('vox.config')
local recorder = require('vox.recorder')
local transcriber = require('vox.transcriber')
local ui = require('vox.ui')

local recording_job = nil
local is_recording = false

function M.setup(opts)
  -- Initialize config with user options
  config.setup(opts)

  -- Create commands
  vim.api.nvim_create_user_command('VoxRecord', function()
    M.toggle_recording()
  end, { desc = "Toggle voice recording" })

  vim.api.nvim_create_user_command('VoxStop', function()
    M.stop_recording_and_transcribe()
  end, { desc = "Stop voice recording" })

  vim.api.nvim_create_user_command('VoxSetModel', function(opts)
      local model = opts.args
      local valid_models = { 'tiny', 'base', 'small', 'medium', 'large' }
      if vim.tbl_contains(valid_models, model) then
        config.options.whisper_model = model
        vim.notify('Whisper model set to: ' .. model)
      else
        vim.notify('Invalid model. Use: tiny, base, small, medium, or large', vim.log.levels.ERROR)
      end
    end,
    {
      nargs = 1,
      complete = function() return { 'tiny', 'base', 'small', 'medium', 'large' } end,
      desc =
      "Set Whisper model size"
    })

  vim.api.nvim_create_user_command('VoxConfig', function()
    vim.notify(vim.inspect(config.get()))
  end, { desc = "Show voice configuration" })

  vim.api.nvim_create_user_command('VoxStatus', function()
    M.show_status()
  end, { desc = "Show voice plugin status" })
end

M.toggle_recording = function()
  -- Toggle recording on/off (simulates hold behavior)
  if is_recording then
    M.stop_recording_and_transcribe()
  else
    M.start_recording()
  end
end

M.start_recording = function()
  if is_recording then
    return
  end

  is_recording = true
  ui.show_recording_window()

  recording_job = recorder.start_recording(function(audio_file)
    -- This callback is called when recording is complete
    M.transcribe_and_insert(audio_file)
  end)

  if not recording_job then
    is_recording = false
  end
end

M.stop_recording_and_transcribe = function()
  if not is_recording then
    return
  end

  is_recording = false
  recorder.stop_recording(recording_job)
end

function M.transcribe_and_insert(audio_file)
  ui.show_transcribing_window()

  transcriber.transcribe(audio_file, function(text, error)
    if error then
      ui.show_error_window(error)
      -- Don't delete audio file on error, even if keep_audio_files is false
      vim.notify('Audio file preserved at: ' .. audio_file, vim.log.levels.WARN)
      return
    end

    if text and text ~= '' then
      M.insert_text(text)
      ui.show_success_window()
    else
      ui.show_error_window('No text was transcribed')
      -- Don't delete audio file when no text was transcribed
      vim.notify('Audio file preserved at: ' .. audio_file, vim.log.levels.WARN)
      return
    end

    -- Clean up audio file if configured and transcription was successful
    if not config.get().keep_audio_files then
      vim.fn.delete(audio_file)
    else
      vim.notify('Audio file saved at: ' .. audio_file, vim.log.levels.INFO)
    end
  end)
end

function M.insert_text(text)
  -- Process text if configured
  if config.get().remove_filler_words then
    text = M.remove_filler_words(text)
  end

  if config.get().auto_punctuation then
    text = M.add_punctuation(text)
  end

  -- Trim whitespace
  text = vim.trim(text)

  -- Insert at cursor position
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()

  -- Add space before if needed
  if col > 0 and not line:sub(col, col):match('%s') then
    text = ' ' .. text
  end

  -- Insert text
  vim.api.nvim_put({ text }, 'c', true, true)
end

function M.remove_filler_words(text)
  local filler_words = { 'um', 'uh', 'like', 'you know', 'I mean' }
  for _, word in ipairs(filler_words) do
    text = text:gsub('%s*' .. word .. '%s*', ' ')
  end
  return text
end

function M.add_punctuation(text)
  -- Simple punctuation addition
  if not text:match('[.!?]$') then
    text = text .. '.'
  end

  -- Capitalize first letter
  text = text:gsub('^%l', string.upper)

  return text
end

function M.show_status()
  local status = {
    whisper_model = config.get().whisper_model,
    whisper_language = config.get().language,
    is_recording = is_recording,
    dependencies = {
      sox = vim.fn.executable('sox') == 1,
      ffmpeg = vim.fn.executable('ffmpeg') == 1,
      whisper = vim.fn.executable('whisper') == 1,
    }
  }

  vim.notify(vim.inspect(status))
end

return M
