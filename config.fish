if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Path modifications for WSL
fish_add_path /usr/local/bin
fish_add_path /home/jay/.local/bin

# Alias for neovim
alias v='nvim'

# Nvm configuration
if functions -q lts_periodically
    lts_periodically
end

if command -s nvm &>/dev/null
    command nvm use lts/* &>/dev/null
end

# Docker configuration
set -x DOCKER_BUILDKIT 1

# Environment variables
set -gx EDITOR nvim
set -gx BROWSER wslview
set -gx GIT_EDITOR $EDITOR
set -gx fish_prompt_pwd_dir_length 0
set -x LS_COLORS (vivid generate snazzy)
set fish_greeting "Welcome back, Jay"

# OS detection
switch (uname)
    case Linux
        set -x OSTYPE Linux
    case Darwin
        set -x OSTYPE MacOS
    case FreeBSD NetBSD DragonFly
        set -x OSTYPE FreeBSD
    case '*'
        set -x OSTYPE unknown
end

# Source additional configuration files
if test -f $HOME/.config/fish/env/index.fish
    source $HOME/.config/fish/env/index.fish
end

# Aliases
if test -f $HOME/.config/fish/aliases/main.fish
    source $HOME/.config/fish/aliases/main.fish
end

if test -f $HOME/.config/fish/aliases/private.fish
    source $HOME/.config/fish/aliases/private.fish
end

if test -f $HOME/.config/fish/aliases/git.fish
    source $HOME/.config/fish/aliases/git.fish
end

# Bun configuration (if you use it in WSL)
set -gx BUN_INSTALL "$HOME/.bun"
fish_add_path $BUN_INSTALL/bin

# WSL-specific configurations
if string match -q "*Microsoft*" (uname -r)
    set -gx PATH /mnt/c/Windows/System32 $PATH

    # Add any other WSL-specific configurations here
end

# Starship prompt initialization
if status is-interactive
    starship init fish | source
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
end

# OpenStack environment setup
if status is-interactive
    # Try to authenticate silently on shell start
    if test -f ~/.config/openstack/atmosphere-openrc.fish
        source ~/.config/openstack/atmosphere-openrc.fish >/dev/null 2>&1
    end
end
