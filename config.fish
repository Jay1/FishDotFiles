# ------------------------------------------------------------------------------
# Universal Settings & Aliases
# ------------------------------------------------------------------------------

# Set default editor and create a shorthand alias
set -gx EDITOR nvim
alias v $EDITOR

# Set other universal environment variables
set -gx GIT_EDITOR $EDITOR
set -gx DOCKER_BUILDKIT 1
set -gx fish_prompt_pwd_dir_length 0

# Bun installation path
set -gx BUN_INSTALL "$HOME/.bun"

# Universal path additions (idempotent)
fish_add_path $HOME/.local/bin
fish_add_path $BUN_INSTALL/bin

# ------------------------------------------------------------------------------
# OS-Specific Configuration
# ------------------------------------------------------------------------------

# Set variables and paths based on the operating system
switch (uname)
    case Darwin # macOS
        set -gx BROWSER open
        # Set Homebrew path for Apple Silicon or Intel Macs
        if test -d /opt/homebrew/bin
            set -l brew_prefix /opt/homebrew
        else if test -d /usr/local/bin
            set -l brew_prefix /usr/local
        end

    case Linux
        # Check for WSL
        if string match -q -- "*Microsoft*" (uname -r)
            set -gx BROWSER wslview
            # Add Windows System32 to PATH for interop
            fish_add_path /mnt/c/Windows/System32
        end
        # Set Homebrew path for Linux (Linuxbrew)
        if test -d /home/linuxbrew/.linuxbrew/bin
            set -l brew_prefix /home/linuxbrew/.linuxbrew
        end
end

# ------------------------------------------------------------------------------
# Tooling & Custom Scripts
# ------------------------------------------------------------------------------

# NVM configuration
if command -s nvm &>/dev/null
    command nvm use lts/* &>/dev/null
end

# Source custom configuration files if they exist
if test -f $HOME/.config/fish/env/index.fish
    source $HOME/.config/fish/env/index.fish
end
if test -f $HOME/.config/fish/aliases/main.fish
    source $HOME/.config/fish/aliases/main.fish
end
if test -f $HOME/.config/fish/aliases/private.fish
    source $HOME/.config/fish/aliases/private.fish
end
if test -f $HOME/.config/fish/aliases/git.fish
    source $HOME/.config/fish/aliases/git.fish
end

# Kitty Shell integration
if test -n "$KITTY_INSTALLATION_DIR"
    source "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_conf.d/kitty-shell-integration.fish"
    set --prepend fish_complete_path "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_completions.d"
end

# ------------------------------------------------------------------------------
# Interactive Session Initialization
# ------------------------------------------------------------------------------

if status is-interactive
    # Set a welcome message
    set fish_greeting "Welcome back, Jay"

    # Generate colors for `ls`
    if command -s vivid &>/dev/null
        set -x LS_COLORS (vivid generate snazzy)
    end

    # Initialize Homebrew environment if the path was set
    if set -q brew_prefix
        eval "($brew_prefix/bin/brew shellenv)"
    end

    # Initialize Starship prompt
    if command -s starship &>/dev/null
        starship init fish | source
    end

    # Silently source OpenStack credentials
    if test -f ~/.config/openstack/atmosphere-openrc.fish
        source ~/.config/openstack/atmosphere-openrc.fish >/dev/null 2>&1
    end
end
