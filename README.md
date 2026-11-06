# Dotfiles

My personal dotfiles for an Arch Linux laptop running dwm on X11, managed with
[GNU Stow](https://www.gnu.org/software/stow/).

## Fresh install

On a new Arch system, clone the repo and run `install.sh` as your user, not root:

```bash
sudo pacman -S --needed git
git clone https://github.com/Zetsumeii/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The script runs these steps in order, and any of them can be run on its own:

| Step | What it does |
|---|---|
| Package groups | Installs the packages in `packages/`, including AUR packages. Builds yay if it's missing. |
| `stow` | Sets up Git LFS, downloads the wallpaper and links the stow packages. |
| `suckless` | Clones, builds and installs [dwm](https://github.com/Zetsumeii/dwm), [dwmblocks](https://github.com/Zetsumeii/dwmblocks) and [dmenu](https://tools.suckless.org/dmenu/). |
| `shell` | Installs Oh My Zsh, Powerlevel10k, TPM and the tmux plugins, then makes zsh the login shell. |

```bash
./install.sh --dry-run        # print what would be run
./install.sh                  # do everything
./install.sh core desktop     # install only these package groups
./install.sh stow suckless    # only link the dotfiles and build suckless
./install.sh shell            # only set up zsh and tmux plugins
```

If a step fails, the script carries on and lists what failed at the end. Stow never
overwrites an existing file: it reports the conflict so you can move the file and run
`./install.sh stow` again.

The script doesn't enable services, so do that yourself afterwards:

```bash
sudo systemctl enable --now NetworkManager firewalld docker bluetooth sshd tailscaled systemd-timesyncd tlp
```

Log in again for the new login shell to apply.

## Packages

Each file in `packages/` is a group that can hold both repo and AUR packages, and the
script tells them apart:

| Group | Contents |
|---|---|
| `core` | Base system, kernels, boot, graphics, audio, network, power |
| `desktop` | X11, session tools, input method, fonts |
| `utils` | Command line tools |
| `apps` | Browsers, chat, media, office |
| `dev` | Compilers, editors, language servers, libraries |
| `infra` | Containers, provisioning, VPNs, file sharing |
| `security` | Security testing tools |
| `gaming` | Steam, Minecraft, chess |

The `gaming` group enables the `multilib` repository when it's needed.

## Stow packages

Each tool has its own stow package, so you only symlink what you want:

```
dotfiles/
├── blocks/spotifyblock.sh, wifiblock.sh
├── flameshot/.config/flameshot/
├── kitty/.config/kitty/
├── nvim/.config/nvim/
├── p10k/.p10k.zsh
├── picom/.config/picom/
├── ranger/.config/ranger/
├── tmux/.tmux.conf
├── xinit/.xinitrc
└── zsh/.zshrc
```

```bash
stow nvim kitty ranger    # link some packages
stow -D nvim              # remove a package's links
```

The wallpaper in `wallpapers/` isn't a stow package: `.xinitrc` reads it straight from the
repo. It's stored with Git LFS, so if it shows up as a small text file, run
`git lfs install --local && git lfs pull`.

## Notes

- The tmux keybinds are vim-like, and the prefix is `Ctrl + s` instead of `Ctrl + b`.
- Flameshot uses `useX11LegacyScreenshot=true`, because dwm has no working screenshot portal.
- Flameshot has to keep running for copied screenshots to stay in the clipboard, so
  `.xinitrc` starts it in the background.
- `dwmblocks` runs `~/spotifyblock.sh` and `~/wifiblock.sh`. The second one is hardcoded
  to the `wlp3s0` network interface.
