# ~/.config/fish/config.fish (Corrected Order)

# ------------------------------------------------------------------------------
# NVM (Node Version Manager) Initialization - MUST BE AT THE TOP
# ------------------------------------------------------------------------------
# This block makes the 'nvm' command available to the shell.
# It must run before any other command that uses 'nvm'.
# This example uses 'bass' to source the standard nvm.sh script.
# If you have not installed bass, run: fisher install edc/bass
set -q NVM_DIR; or set NVM_DIR "$HOME/.nvm"
if test -s "$NVM_DIR/nvm.sh"
    bass source "$NVM_DIR/nvm.sh" --no-use ';'
end
# ------------------------------------------------------------------------------

if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Path modifications
fish_add_path /usr/local/bin
fish_add_path /home/jay/.local/bin

# Alias for neovim
alias v='nvim'

# Nvm periodic update and version setting
# These can only run AFTER nvm is initialized above.
if functions -q lts_periodically
    status --is-interactive; and lts_periodically &
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
set -gx COLORTERM truecolor
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

# Bun configuration
set -gx BUN_INSTALL "$HOME/.bun"
fish_add_path $BUN_INSTALL/bin

# WSL-specific configurations
if string match -q "*Microsoft*" (uname -r)
    # For consistency, fish_add_path is a good choice here too
    fish_add_path /mnt/c/Windows/System32
end

# Interactive session specific configurations
if status is-interactive
    # Starship prompt initialization
    if command -s starship &>/dev/null
        starship init fish | source
    end

    # Homebrew shell environment
    if test -f /home/linuxbrew/.linuxbrew/bin/brew
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    end

    # OpenStack environment setup
    if test -f ~/.config/openstack/atmosphere-openrc.fish
        source ~/.config/openstack/atmosphere-openrc.fish >/dev/null 2>&1
    end
end

# opencode
fish_add_path /home/jay/.opencode/bin
