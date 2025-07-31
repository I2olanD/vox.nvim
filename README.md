# Vox - Voice Transcription Plugin for Neovim

A simple Neovim plugin that records voice audio, transcribes it using local Whisper, and inserts the text at cursor position.

## Usage

### Default Keybinding

- `<leader>vr` - Press to start recording, press again to stop and transcribe

### Commands

- `:VoiceStop` - Stop recording if in progress
- `:VoiceSetModel <size>` - Set Whisper model (tiny/base/small/medium/large)
- `:VoiceConfig` - Show current configuration
- `:VoiceStatus` - Show plugin status and dependencies

## Installation

### Using lazy.nvim

```lua
{
  "I2olanD/vox.nvim",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim"
  },
  config = function()
    require('vox').setup({
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
    })
  end,
  keys = {
    { "<leader>vr", desc = "Toggle voice recording" }
  }
}
```

### Dependencies

1. **Audio recording** (macOS):

   ```bash
   brew install sox
   # or ffmpeg as fallback
   brew install ffmpeg
   ```

2. **Whisper** (transcription):

   ```bash
   pip install openai-whisper
   ```

3. **Microphone permissions**: Grant terminal/Neovim microphone access in System Preferences

## Troubleshooting

### Check dependencies

```vim
:VoiceStatus
```

## License

MIT
