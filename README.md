# Vox - Voice Transcription Plugin for Neovim

A simple Neovim plugin that records voice audio, transcribes it using local Whisper, and inserts the text at cursor position.

## Features

- **Press to start/stop recording**: Simple toggle mechanism
- **Local transcription**: Uses OpenAI Whisper running locally
- **Visual feedback**: Floating window shows recording/transcription status
- **Text processing**: Removes filler words, adds punctuation
- **Instant insertion**: Transcribed text appears at cursor position

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
    require('vox').setup()
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

## Usage

### Default Keybinding

- `<leader>vr` - Press to start recording, press again to stop and transcribe

### Commands

- `:VoiceStop` - Stop recording if in progress
- `:VoiceSetModel <size>` - Set Whisper model (tiny/base/small/medium/large)
- `:VoiceConfig` - Show current configuration
- `:VoiceStatus` - Show plugin status and dependencies

## Configuration

```lua
require('vox').setup({
  -- Audio settings
  max_recording_duration = 60,    -- maximum recording time in seconds

  -- Transcription settings
  whisper_model = "base",         -- model size
  language = "en",                -- language code
  remove_filler_words = true,     -- remove um, uh, like
  auto_punctuation = true,        -- add punctuation

  -- UI settings
  show_floating_window = true,    -- show progress windows

  -- File settings
  temp_dir = "~/.local/share/nvim/vox/",
  keep_audio_files = false,       -- delete audio after transcription

  -- Keybinding
  keybinding = "<leader>vr"       -- change to your preference
})
```

## How it works

1. Press `<leader>vr` to start recording
2. Speak your text
3. Press `<leader>vr` again to stop
4. Wait for transcription (shows "Transcribing...")
5. Text is inserted at cursor position

## Troubleshooting

### Check dependencies

```vim
:VoiceStatus
```

### Common issues

1. **"Microphone access denied"**: Grant terminal microphone permissions in System Preferences → Security & Privacy → Microphone
2. **"Whisper not found"**: Install with `pip install openai-whisper`
3. **No audio recorded**: Check microphone is working with `sox -d test.wav trim 0 3`
4. **Recording doesn't stop**: Use `:VoiceStop` command

## License

MIT

