if status is-interactive
    # Commands to run in interactive sessions can go here
end



contains /usr/local/bin $PATH
or set PATH /usr/local/bin $PATH
contains /opt/homebrew/bin
or set PATH /opt/homebrew/bin $PATH
contains /Users/jay/.local/bin
or set PATH /Users/jay/.local/bin $PATH

alias v='nvim'
set -gx EDITOR nvim
set -gx GIT_EDITOR $EDITOR
set -gx fish_prompt_pwd_dir_length 0

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

if [ -f $HOME/.config/fish/env/index.fish ]
    source $HOME/.config/fish/env/index.fish
end

#
### ALIAS
#
# Main
if [ -f $HOME/.config/fish/aliases/main.fish ]
    source $HOME/.config/fish/aliases/main.fish
end

# Private aliases (e.g. with servers address...)
## aliases/private.fish will be ignored by git (.gitignore)
if [ -f $HOME/.config/fish/aliases/private.fish ]
    source $HOME/.config/fish/aliases/private.fish
end

# Git
if [ -f $HOME/.config/fish/aliases/git.fish ]
    source $HOME/.config/fish/aliases/git.fish
end

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# Kitty Shell integration
if test -n "$KITTY_INSTALLATION_DIR"
    source "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_conf.d/kitty-shell-integration.fish"
    set --prepend fish_complete_path "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_completions.d"
end
