-- Test different recording modes
-- Run this in Neovim with :source %

vim.opt.runtimepath:append(vim.fn.getcwd())

-- Test fixed mode
print("Testing Fixed Duration Mode (3 seconds)...")
require('vox').setup({
  recording_mode = "fixed",
  fixed_duration = 3,
  show_floating_window = true,
})

-- Test mode switching
vim.cmd('VoiceSetMode fixed')
local config = require('vox.config').get()
assert(config.recording_mode == "fixed", "Mode should be set to fixed")
print("✓ Fixed mode set correctly")

-- Test hold mode
vim.cmd('VoiceSetMode hold')
config = require('vox.config').get()
assert(config.recording_mode == "hold", "Mode should be set to hold")
print("✓ Hold mode set correctly")

-- Test silence mode
vim.cmd('VoiceSetMode silence')
config = require('vox.config').get()
assert(config.recording_mode == "silence", "Mode should be set to silence")
print("✓ Silence mode set correctly")

-- Test invalid mode
local ok = pcall(vim.cmd, 'VoiceSetMode invalid')
assert(not ok, "Invalid mode should fail")
print("✓ Invalid mode rejected correctly")

print("\nAll mode tests passed!")