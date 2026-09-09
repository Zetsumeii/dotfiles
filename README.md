# 🧩 Dotfiles

My personal dotfiles — a curated setup for productivity, efficiency, and style.
My TMUX configuration has vim like keybinds.
Easily managed using [GNU Stow](https://www.gnu.org/software/stow/) for simple symlink management.

---

## ⚙️ Requirements

Before installing, make sure you have the following tools:

- [**GNU Stow**](https://www.gnu.org/software/stow/) – to symlink configuration files easily
- [**TPM (Tmux Plugin Manager)**](https://github.com/tmux-plugins/tpm) – for managing tmux plugins

You can install them with your package manager, for example:

```bash
# On Arch / Manjaro
sudo pacman -S stow tmux

# On Debian / Ubuntu
sudo apt install stow tmux

# On Fedora
sudo dnf install stow tmux
```

## 🚀 Installation

```bash
git clone https://github.com/Zetsumeii/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

Each tool lives in its own [stow package](https://www.gnu.org/software/stow/), so you
only ever symlink what you actually want:

```
dotfiles/
├── kitty/.config/kitty/
├── nvim/.config/nvim/
├── ranger/.config/ranger/
├── tmux/.tmux.conf
└── zsh/.zshrc
```

Stow the packages you want:

```bash
stow nvim kitty ranger
```

Or grab everything:

```bash
stow nvim kitty ranger tmux zsh
```

To remove a package's symlinks again:

```bash
stow -D nvim
```

## 🧠 Notes

My TMUX prefix is <CTRL + s> instead of <CTRL + b>
