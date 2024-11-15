if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Path modifications for WSL
contains /usr/local/bin $PATH
or set PATH /usr/local/bin $PATH
contains /home/jay/.local/bin $PATH
or set PATH /home/jay/.local/bin $PATH

# Alias for neovim
alias v='nvim'

# Environment variables
set -gx EDITOR nvim
set -gx BROWSER wslview
set -gx GIT_EDITOR $EDITOR
set -gx fish_prompt_pwd_dir_length 0
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
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# WSL-specific configurations
if string match -q "*Microsoft*" (uname -r)
    # WSL-specific path additions (if needed)
    # set -gx PATH /mnt/c/Windows/System32 $PATH

    # Add any other WSL-specific configurations here
end

# Starship prompt initialization
starship init fish | source
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# OpenStack environment setup
if status is-interactive
    # Try to authenticate silently on shell start
    if test -f ~/.config/openstack/atmosphere-openrc.fish
        source ~/.config/openstack/atmosphere-openrc.fish >/dev/null 2>&1
    end
end
