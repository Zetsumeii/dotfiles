#!/usr/bin/env bash
# Set up a fresh Arch system: packages from packages/*.txt, stow packages, suckless builds and shell plugins.
# Repo and AUR packages are told apart automatically, so a group file can hold both.
set -euo pipefail

DOTFILES_DIR="$(dirname "$(readlink -f "$0")")"
PACKAGES_DIR="$DOTFILES_DIR/packages"
ALL_GROUPS=(core desktop utils apps dev infra security gaming)
STOW_PACKAGES=(blocks flameshot kitty nvim p10k picom ranger tmux xinit zsh)
# name=url, cloned over HTTPS into ~/name because a fresh system has no SSH key yet.
SUCKLESS=(
    dwm=https://github.com/Zetsumeii/dwm.git
    dwmblocks=https://github.com/Zetsumeii/dwmblocks.git
    dmenu=https://git.suckless.org/dmenu
)
# path=url under ~. Cloned directly: the Oh My Zsh installer would overwrite the stowed .zshrc.
SHELL_REPOS=(
    .oh-my-zsh=https://github.com/ohmyzsh/ohmyzsh.git
    .oh-my-zsh/custom/themes/powerlevel10k=https://github.com/romkatv/powerlevel10k.git
    .tmux/plugins/tpm=https://github.com/tmux-plugins/tpm.git
)
LOGIN_SHELL=/usr/bin/zsh
DRY_RUN=false
failed=()

usage() {
    cat <<USAGE
Usage: ./install.sh [--dry-run] [step...]

With no step, runs all of them. Steps:

  ${ALL_GROUPS[*]}
                  install that package group
  stow            link the dotfiles: ${STOW_PACKAGES[*]}
  suckless        clone, build and install dwm, dwmblocks and dmenu
  shell           install Oh My Zsh, Powerlevel10k, TPM and its plugins, make zsh the login shell

  -n, --dry-run   print what would be run, change nothing
  -h, --help      show this help
USAGE
}

# Print the active packages of a group, without comments or blank lines.
read_group() {
    sed 's/#.*//' "$PACKAGES_DIR/$1.txt" | awk 'NF { print $1 }'
}

run() {
    if "$DRY_RUN"; then
        echo "+ $*"
    else
        "$@"
    fi
}

enable_multilib() {
    grep -q '^\[multilib\]' /etc/pacman.conf && return 0
    run sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
}

# Build yay by hand: the AUR helper can't come from the AUR helper.
bootstrap_yay() {
    command -v yay >/dev/null && return 0
    run sudo pacman -S --needed base-devel git
    if "$DRY_RUN"; then
        echo "+ build yay from https://aur.archlinux.org/yay.git"
        return 0
    fi
    local build_dir
    build_dir="$(mktemp -d)"
    git clone https://aur.archlinux.org/yay.git "$build_dir/yay"
    (cd "$build_dir/yay" && makepkg -si -r --needed)
    rm -rf "$build_dir"
}

install_packages() {
    [[ " $* " == *" gaming "* ]] && enable_multilib
    run sudo pacman -Syu

    local repo_index aur=() repo=() group pkg
    repo_index="$(pacman -Slq | sort -u)"

    for group in "$@"; do
        mapfile -t repo < <(comm -12 <(read_group "$group" | sort -u) <(echo "$repo_index"))
        mapfile -t -O "${#aur[@]}" aur < <(comm -23 <(read_group "$group" | sort -u) <(echo "$repo_index"))
        ((${#repo[@]})) || continue
        echo "==> $group: ${#repo[@]} repo packages"
        run sudo pacman -S --needed -- "${repo[@]}" || failed+=("group $group (repo packages)")
    done

    if ((${#aur[@]})); then
        echo "==> ${#aur[@]} AUR packages"
        bootstrap_yay
        # One at a time, so a dead AUR package doesn't take the others down with it.
        for pkg in "${aur[@]}"; do
            run yay -S --needed -- "$pkg" || failed+=("$pkg")
        done
    fi
}

# Stow refuses to overwrite an existing file, so a conflict is reported, never clobbered.
stow_dotfiles() {
    local pkg
    echo "==> Linking dotfiles"
    # A fresh clone only holds LFS pointers until git-lfs, from the core group, is set up.
    run git -C "$DOTFILES_DIR" lfs install --local || failed+=("git lfs install")
    run git -C "$DOTFILES_DIR" lfs pull || failed+=("git lfs pull")
    for pkg in "${STOW_PACKAGES[@]}"; do
        run stow -d "$DOTFILES_DIR" -t "$HOME" -R "$pkg" || failed+=("stow $pkg")
    done
}

# An existing ~/name is built as it is, so local work is never pulled over.
build_suckless() {
    local entry name url dir
    for entry in "${SUCKLESS[@]}"; do
        name="${entry%%=*}"
        url="${entry#*=}"
        dir="$HOME/$name"
        echo "==> Building $name"
        { [[ -d "$dir" ]] || run git clone "$url" "$dir"; } &&
            run make -C "$dir" clean all &&
            run sudo make -C "$dir" install ||
            failed+=("build $name")
    done
}

# Runs after stow: TPM reads its plugin list from the stowed .tmux.conf.
setup_shell() {
    local entry path_in_home url
    echo "==> Setting up zsh and tmux"
    for entry in "${SHELL_REPOS[@]}"; do
        path_in_home="${entry%%=*}"
        url="${entry#*=}"
        [[ -d "$HOME/$path_in_home/.git" ]] ||
            run git clone --depth=1 "$url" "$HOME/$path_in_home" ||
            failed+=("clone $path_in_home")
    done
    run "$HOME/.tmux/plugins/tpm/bin/install_plugins" || failed+=("tmux plugins")
    [[ "$(getent passwd "$(id -un)" | cut -d: -f7)" == "$LOGIN_SHELL" ]] ||
        run sudo chsh -s "$LOGIN_SHELL" "$(id -un)" ||
        failed+=("chsh")
}

main() {
    local groups=() do_stow=false do_suckless=false do_shell=false
    while (($#)); do
        case "$1" in
            -n | --dry-run) DRY_RUN=true ;;
            -h | --help) usage; return 0 ;;
            -*) echo "Unknown option: $1" >&2; usage >&2; return 2 ;;
            stow) do_stow=true ;;
            suckless) do_suckless=true ;;
            shell) do_shell=true ;;
            *)
                if [[ ! -f "$PACKAGES_DIR/$1.txt" ]]; then
                    echo "Unknown step: $1 (available: ${ALL_GROUPS[*]} stow suckless shell)" >&2
                    return 2
                fi
                groups+=("$1")
                ;;
        esac
        shift
    done
    if ! ((${#groups[@]})) && ! "$do_stow" && ! "$do_suckless" && ! "$do_shell"; then
        groups=("${ALL_GROUPS[@]}")
        do_stow=true
        do_suckless=true
        do_shell=true
    fi

    if ((EUID == 0)); then
        echo "Run this as your user, not root: sudo is called when needed and makepkg refuses root." >&2
        return 1
    fi

    ((${#groups[@]})) && install_packages "${groups[@]}"
    "$do_stow" && stow_dotfiles
    "$do_suckless" && build_suckless
    "$do_shell" && setup_shell

    if ((${#failed[@]})); then
        echo "==> Failed:" >&2
        printf '  %s\n' "${failed[@]}" >&2
        return 1
    fi
    echo "==> Done"
}

main "$@"
