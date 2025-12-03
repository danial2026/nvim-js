# Neovim Configuration for JavaScript/React/Next.js Development

A specialized Neovim configuration optimized for JavaScript, TypeScript, React, and Next.js development.

## Features

- 🚀 **LSP Support**: TypeScript, JavaScript, Tailwind CSS, HTML, CSS, ESLint
- 🌳 **Tree-sitter**: Enhanced syntax highlighting and code navigation
- 🎨 **Auto-formatting**: Prettier with format-on-save
- 🔍 **Linting**: ESLint integration with auto-fix
- 💬 **DeepSeek Chat**: AI-powered chat interface (requires setup)
- ⚡ **Fast**: Optimized for performance with lazy loading
- 🎯 **React/Next.js**: Specialized keybindings and tools

## Prerequisites

- Neovim 0.8 or higher
- Git
- Node.js and npm (for JavaScript/TypeScript development)
- `curl` command (for DeepSeek API integration)

## Installation

### 1. Clone Required Repositories

First, clone the required configuration repositories into your `~/.config/` directory:

```bash
# Clone nvim-js (this configuration)
git clone https://github.com/danial2026/nvim-js ~/.config/nvim-js

# Clone nvim-general (base configuration)
git clone https://github.com/danial2026/nvim-general ~/.config/nvim-general

# Clone nvim-deepseek-chat (AI chat integration)
git clone https://github.com/danial2026/nvim-deepseek-chat ~/.config/nvim-deepseek-chat
```

### 2. Configure Shell Environment

Add the following to your `~/.zshrc` (for Zsh) or `~/.bashrc` (for Bash):

```bash
# Neovim alias for JavaScript/React/Next.js development
alias nvimj='NVIM_APPNAME=nvim-js nvim'

# DeepSeek API Key (replace with your actual API key)
export DEEPSEEK_API_KEY=your-api-key-here
```

After adding these lines, reload your shell configuration:

```bash
# For Zsh
source ~/.zshrc

# For Bash
source ~/.bashrc
```

**Note**: Replace `your-api-key-here` with your actual DeepSeek API key. You can get one from [DeepSeek's website](https://www.deepseek.com/).

### 3. Launch Neovim

Use the alias to launch Neovim with this configuration:

```bash
nvimj
```

Or manually:

```bash
NVIM_APPNAME=nvim-js nvim
```

## Configuration

This configuration automatically loads plugins and settings from:

- `~/.config/nvim-general/` - Base Neovim configuration
- `~/.config/nvim-deepseek-chat/` - DeepSeek chat integration

## Keybindings

### General

- `<leader>` - Default leader key (space)

### React/Next.js Development

- `<leader>nr` - Run Next.js dev server
- `<leader>rs` - Run React dev server (CRA/Vite)
- `<leader>nb` - Build production
- `<leader>nt` - Run tests
- `<leader>nq` - Kill terminal process
- `<leader>db` - Run npm script from package.json

### DeepSeek Chat

- `<leader>dc` - Toggle DeepSeek Chat window

### LSP

- `K` - Hover documentation
- `gd` - Go to definition
- `gr` - Go to references
- `<leader>ca` - Code actions
- `<leader>lf` - Format buffer

## Plugins Included

- **Lazy.nvim** - Plugin manager
- **nvim-lspconfig** - LSP configuration
- **nvim-treesitter** - Syntax highlighting
- **mason.nvim** - LSP installer
- **conform.nvim** - Code formatting
- **nvim-lint** - Linting
- **lspsaga.nvim** - Enhanced LSP UI
- **nvim-autopairs** - Auto-pair brackets
- **nvim-ts-autotag** - Auto-close HTML/JSX tags
- **emmet-vim** - HTML/JSX expansion
- **nvim-colorizer** - Color highlighting
- **neoterm** - Terminal integration

## Troubleshooting

### DeepSeek Chat not working

- Ensure `DEEPSEEK_API_KEY` is set in your shell environment
- Verify the API key is valid
- Check that `curl` is installed

### LSP not starting

- Run `:Mason` to install missing LSP servers
- Check `:checkhealth` for diagnostics

### Plugins not loading

- Ensure `nvim-general` is cloned correctly
- Check that `~/.config/nvim-general/plugins.lua` exists
- Restart Neovim after cloning repositories

## License

This configuration is provided as-is for personal use.
