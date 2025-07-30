-- Test recording functionality
-- Run this in Neovim with :source %

vim.opt.runtimepath:append(vim.fn.getcwd())
require('vox').setup()

local recorder = require('vox.recorder')
local config = require('vox.config')

-- Test 1: Check dependencies
print("Test 1: Checking dependencies...")
local has_sox = vim.fn.executable('sox') == 1
local has_ffmpeg = vim.fn.executable('ffmpeg') == 1
print("  sox available: " .. tostring(has_sox))
print("  ffmpeg available: " .. tostring(has_ffmpeg))
assert(has_sox or has_ffmpeg, "Need either sox or ffmpeg installed")
print("✓ Dependencies check passed")

-- Test 2: Test audio file generation
print("\nTest 2: Testing audio file generation...")
local temp_dir = config.get().temp_dir
assert(vim.fn.isdirectory(temp_dir) == 1, "Temp directory should exist")
print("✓ Temp directory exists: " .. temp_dir)

-- Test 3: Test recording start (3 second test)
print("\nTest 3: Testing 3-second recording...")
print("Recording will start in 2 seconds...")
vim.defer_fn(function()
  print("🔴 Recording started...")
  
  local job_id = recorder.start_recording(function(audio_file)
    print("✓ Recording completed: " .. audio_file)
    
    -- Check file exists
    assert(vim.fn.filereadable(audio_file) == 1, "Audio file should exist")
    
    -- Check file size
    local size = vim.fn.getfsize(audio_file)
    print("  Audio file size: " .. size .. " bytes")
    assert(size > 0, "Audio file should not be empty")
    
    -- Clean up
    vim.fn.delete(audio_file)
    print("✓ Cleaned up test file")
    print("\nAll recording tests passed!")
  end)
  
  assert(job_id and job_id > 0, "Recording job should start successfully")
  
  -- Stop after 3 seconds
  vim.defer_fn(function()
    recorder.stop_recording(job_id)
    print("⏹ Recording stopped")
  end, 3000)
end, 2000)