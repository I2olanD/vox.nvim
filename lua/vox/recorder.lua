local M = {}
local config = require('vox.config')

local function get_audio_filename()
  local timestamp = os.date('%Y%m%d_%H%M%S')
  local temp_dir = config.get().temp_dir or vim.fn.expand("~/.local/share/nvim/vox/")

  -- Ensure temp directory exists
  vim.fn.mkdir(temp_dir, "p")

  return temp_dir .. 'recording_' .. timestamp .. '.wav'
end

local function check_dependencies()
  if vim.fn.executable('sox') == 1 then
    return 'sox', nil
  elseif vim.fn.executable('ffmpeg') == 1 then
    return 'ffmpeg', nil
  else
    return nil, 'No audio recording tool found. Install sox (brew install sox) or ffmpeg'
  end
end

function M.start_recording(callback)
  local recorder, err = check_dependencies()
  if err then
    vim.notify(err, vim.log.levels.ERROR)
    return nil
  end

  local audio_file = get_audio_filename()
  local cmd

  if recorder == 'sox' then
    -- sox command for recording on macOS
    cmd = {
      'sox',
      '-d',                                     -- default audio device (microphone)
      '-r', tostring(config.get().sample_rate), -- sample rate
      '-c', '1',                                -- mono
      '-b', '16',                               -- 16-bit
      '-t', 'wav',                              -- output format
      audio_file,
      'trim', '0', tostring(config.get().max_recording_duration)
    }
  else
    -- ffmpeg command for recording on macOS
    -- First list devices with: ffmpeg -f avfoundation -list_devices true -i ""
    cmd = {
      'ffmpeg',
      '-f', 'avfoundation',   -- macOS audio input
      '-i', ':default',       -- default audio input device (microphone)
      '-ar', tostring(config.get().sample_rate),
      '-ac', '1',             -- mono
      '-acodec', 'pcm_s16le', -- 16-bit PCM
      '-t', tostring(config.get().max_recording_duration),
      '-y',                   -- overwrite output
      audio_file
    }
  end

  -- Start recording in background
  local job_id = vim.fn.jobstart(cmd, {
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        if callback then
          callback(audio_file)
        end
      else
        vim.notify('Recording failed with exit code: ' .. exit_code, vim.log.levels.ERROR)
      end
    end,
    on_stderr = function(_, data)
      -- Log stderr for debugging if needed
      if data and #data > 0 then
        for _, line in ipairs(data) do
          if line ~= '' and line:match('error') then
            vim.fn.writefile({ line }, config.get().temp_dir .. 'recorder.log', 'a')
          end
        end
      end
    end
  })

  if job_id <= 0 then
    vim.notify('Failed to start recording', vim.log.levels.ERROR)
    return nil
  end

  return job_id
end

function M.stop_recording(job_id)
  if job_id and job_id > 0 then
    -- Send interrupt signal to stop recording
    vim.fn.jobstop(job_id)
  end
end

return M

