# ~/.config/fish/config.fish (Corrected Order)

# Disable async prompt (conflicts with Starship)
set -g async_prompt_enable 0

# Path modifications - MUST BE FIRST
fish_add_path /usr/local/bin
fish_add_path /home/jay/.local/bin

# Bun first on PATH (no globals; rely on universal var or literal path)
if test -d "$HOME/.bun/bin"
    fish_add_path -m "$HOME/.bun/bin"
end

# opencode
fish_add_path /home/jay/.opencode/bin

# Homebrew shell env (loads PATH for brew)
if test -f /home/linuxbrew/.linuxbrew/bin/brew
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
end

# WSL-specific configurations
if string match -q "*Microsoft*" (uname -r)
    fish_add_path /mnt/c/Windows/System32
end

# ------------------------------------------------------------------------------
# NVM (Node Version Manager) Initialization
# ------------------------------------------------------------------------------
# This block makes the 'nvm' command available to the shell.
# It must run before any other command that uses 'nvm'.
# This example uses 'bass' to source the standard nvm.sh script.
# If you have not installed bass, run: fisher install edc/bass
set -q NVM_DIR; or set NVM_DIR "$HOME/.nvm"
if test -s "$NVM_DIR/nvm.sh"
    bass source "$NVM_DIR/nvm.sh" --no-use 2>/dev/null
end
# ------------------------------------------------------------------------------

# Alias for neovim
alias v='nvim'

# Nvm periodic update and version setting
# These can only run AFTER nvm is initialized above.
if functions -q lts_periodically
    status --is-interactive; and lts_periodically &
end
if type -q nvm
    nvm use "lts/*" &>/dev/null
end

# Docker configuration
set -x DOCKER_BUILDKIT 1

# Environment variables
set -gx EDITOR nvim
set -gx BROWSER wslview
set -gx GIT_EDITOR $EDITOR
set -gx COLORTERM truecolor
set -gx fish_prompt_pwd_dir_length 0
if type -q vivid
    set -x LS_COLORS (vivid generate snazzy)
end
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

# Interactive session specific configurations
if status is-interactive
    # OpenStack environment setup
    if test -f ~/.config/openstack/atmosphere-openrc.fish
        source ~/.config/openstack/atmosphere-openrc.fish >/dev/null 2>&1
    end

    # Starship prompt initialization - MUST BE LAST in interactive block
    if type -q starship
        starship init fish | source
    end
end
# ~/.config/fish/config.fish

# Set up tmux if we're in an interactive session
if status is-interactive
    and not set -q TMUX
    and set -q SSH_CONNECTION
    # Check if tmux exists before trying to exec, to avoid locking yourself out
    if type -q tmux
        exec tmux new-session -A -s main
    end
end
