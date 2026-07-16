# Core environment
fish_add_path /usr/local/bin $HOME/.local/bin $HOME/.opencode/bin

set -gx EDITOR nvim
set -gx GIT_EDITOR $EDITOR
set -gx COLORTERM truecolor
set -gx DOCKER_BUILDKIT 1
set -g fish_prompt_pwd_dir_length 0
set -g fish_greeting "Welcome back, Jay"

alias v='nvim'

if command -q vivid
    set -gx LS_COLORS (vivid generate snazzy)
end

# Platform
set -l kernel (uname -r)
if string match -qi '*microsoft*' $kernel
    set -gx BROWSER $HOME/.local/bin/google-chrome-wsl
    fish_add_path /mnt/c/Windows/System32
else
    set -gx BROWSER wslview
end

switch (uname)
    case Linux
        set -gx OSTYPE Linux
    case Darwin
        set -gx OSTYPE MacOS
    case FreeBSD NetBSD DragonFly
        set -gx OSTYPE FreeBSD
    case '*'
        set -gx OSTYPE unknown
end

# Shared environment and aliases
if test -f $HOME/.config/fish/env/index.fish
    source $HOME/.config/fish/env/index.fish
end

for file in main private git
    set -l alias_file $HOME/.config/fish/aliases/$file.fish
    if test -f $alias_file
        source $alias_file
    end
end

# Toolchains
if test -x /home/linuxbrew/.linuxbrew/bin/brew
    eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
end

if test -x $HOME/.local/bin/mise
    $HOME/.local/bin/mise activate fish | source
end

# Mise owns runtime activation; keep legacy nvm paths out of PATH.
set -l clean_path
for path_entry in $PATH
    if string match -qr '^/home/jay/\.local/share/nvm/v[^/]+/bin' -- $path_entry
        continue
    end
    if string match -qr '^/home/jay/\.nvm/(current|versions/node/[^/]+)/bin' -- $path_entry
        continue
    end
    set -a clean_path $path_entry
end
set -gx PATH $clean_path

if test -d $HOME/.bun/bin
    fish_add_path $HOME/.bun/bin
end

# Interactive integrations
if status is-interactive
    if command -q starship
        starship init fish | source
    end

    if test -f $HOME/.config/openstack/atmosphere-openrc.fish
        source $HOME/.config/openstack/atmosphere-openrc.fish >/dev/null 2>&1
    end
end
