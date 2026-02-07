# Dotfiles

Personal configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Prerequisites

- GNU Stow
- Neovim
- Tmux
- Starship
- Lazygit
- Fastfetch
- Zoxide
- FZF
- Ripgrep

## Installation

```bash
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### Stow individual packages

```bash
stow nvim
stow tmux
stow bashrc
```

### Stow all packages

```bash
stow */
```

## Available Packages

| Package | Target |
|---------|--------|
| bashrc | `~/.bashrc` |
| fastfetch | `~/.config/fastfetch/` |
| lazygit | `~/.config/lazygit/` |
| nvim | `~/.config/nvim/` |
| opencode | `~/.config/opencode/` |
| sqlserver | `~/bin/sqlcmd` |
| starship | `~/.config/starship.toml` |
| tmux | `~/.tmux.conf`, `~/.config/tmux-sessionizer/`, `~/.local/bin/` |

## GNU Stow Best Practices

### How it works

Stow creates symlinks from your home directory to files in this repo. Each top-level directory is a "package" containing files structured as they should appear relative to `$HOME`.

```
dotfiles/
└── nvim/
    └── .config/
        └── nvim/
            └── init.lua    →  ~/.config/nvim/init.lua
```

### Removing symlinks

```bash
stow -D nvim
```

### Restow (refresh symlinks)

```bash
stow -R nvim
```

### Handling conflicts

If stow reports conflicts, you likely have existing files at the target location. Back them up or remove them first:

```bash
mv ~/.bashrc ~/.bashrc.bak
stow bashrc
```

### Simulate before applying

Preview what stow will do without making changes:

```bash
stow -n -v nvim
```
