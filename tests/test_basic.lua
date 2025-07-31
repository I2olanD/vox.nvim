-- Basic test for vox plugin
-- Run this in Neovim with :source %

-- Add plugin to runtime path
vim.opt.runtimepath:append(vim.fn.getcwd())

-- Load the plugin
require('vox').setup({
  recording_mode = "fixed",
  fixed_duration = 3,
  show_floating_window = true,
})

-- Test commands exist
local commands = vim.api.nvim_get_commands({})
assert(commands.VoxSetMode, "VoxSetMode command should exist")
assert(commands.VoxSetModel, "VoxSetModel command should exist")
assert(commands.VoxConfig, "VoxConfig command should exist")
assert(commands.VoxStatus, "VoxStatus command should exist")

print("✓ All commands registered successfully")

-- Test configuration
local config = require('vox.config').get()
assert(config.recording_mode == "fixed", "Recording mode should be 'fixed'")
assert(config.fixed_duration == 3, "Fixed duration should be 3")
print("✓ Configuration loaded correctly")

-- Test status command
vim.cmd('VoxStatus')

print("\nBasic tests passed! Try running :VoxRecord to test recording.")

