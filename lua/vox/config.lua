local M = {}

M.defaults = {
  -- Audio settings
  max_recording_duration = 60, -- seconds
  audio_format = "wav",
  sample_rate = 16000,

  -- Transcription settings
  whisper_model = "base",
  language = "en",
  remove_filler_words = true,
  auto_punctuation = true,

  -- UI settings
  show_floating_window = true,
  show_status_updates = true,

  -- File settings
  temp_dir = vim.fn.expand("~/.local/share/nvim/vox/"),
  keep_audio_files = false,

  -- Keybinding for hold-to-record
  keybinding = "<leader>vr"
}

M.options = nil

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})

  -- Ensure temp directory exists
  vim.fn.mkdir(M.options.temp_dir, "p")
end

function M.get()
  -- Return defaults if setup hasn't been called yet
  if not M.options then
    return M.defaults
  end
  return M.options
end

return M

