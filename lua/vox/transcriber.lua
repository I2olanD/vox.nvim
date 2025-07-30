local M = {}
local config = require('vox.config')

local function check_whisper()
  if vim.fn.executable('whisper') ~= 1 then
    return false, 'Whisper not found. Install with: pip install openai-whisper'
  end
  return true, nil
end

function M.transcribe(audio_file, callback)
  local ok, err = check_whisper()
  if not ok then
    callback(nil, err)
    return
  end

  local output_file = audio_file:gsub('%.wav$', '.txt')

  local cmd = {
    'whisper',
    audio_file,
    '--model', config.get().whisper_model,
    '--language', config.get().language,
    '--output_format', 'txt',
    '--output_dir', config.get().temp_dir,
    '--fp16', 'False', -- Disable half-precision for compatibility
    '--verbose', 'False'
  }

  vim.fn.jobstart(cmd, {
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        -- Read the transcribed text
        local text_file = audio_file:gsub('%.wav$', '.txt')
        local ok, lines = pcall(vim.fn.readfile, text_file)

        if ok and lines then
          local text = table.concat(lines, ' ')
          callback(text, nil)

          -- Clean up text file
          vim.fn.delete(text_file)
        else
          callback(nil, 'Failed to read transcription file')
        end
      else
        callback(nil, 'Transcription failed with exit code: ' .. exit_code)
      end
    end,
    on_stderr = function(_, data)
      -- Log stderr for debugging
      if data and #data > 0 then
        for _, line in ipairs(data) do
          if line ~= '' and not line:match('^%s*$') then
            -- Only log non-empty lines
            vim.fn.writefile({ line }, config.get().temp_dir .. 'transcriber.log', 'a')
          end
        end
      end
    end
  })
end

-- Alternative implementation using whisper Python API directly
function M.transcribe_python(audio_file, callback)
  local python_script = [[
import whisper
import sys

audio_file = sys.argv[1]
model_size = sys.argv[2]
language = sys.argv[3]

model = whisper.load_model(model_size)
result = model.transcribe(audio_file, language=language)
print(result["text"])
]]

  local script_file = config.get().temp_dir .. 'transcribe.py'
  vim.fn.writefile(vim.split(python_script, '\n'), script_file)

  local cmd = {
    'python3',
    script_file,
    audio_file,
    config.get().whisper_model,
    config.get().language
  }

  local output = {}
  vim.fn.jobstart(cmd, {
    on_stdout = function(_, data)
      if data then
        vim.list_extend(output, data)
      end
    end,
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        local text = table.concat(output, ' '):gsub('^%s+', ''):gsub('%s+$', '')
        callback(text, nil)
      else
        callback(nil, 'Python transcription failed')
      end

      -- Clean up script file
      vim.fn.delete(script_file)
    end
  })
end

return M

