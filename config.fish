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

# WSL-specific path interop is handled globally via /etc/wsl.conf
# (appendWindowsPath=true), so we do not re-add Windows paths here.

# OpenClaw env compatibility cleanup
if set -q CLAWDBOT_TMUX_SOCKET_DIR
    if not set -q OPENCLAW_TMUX_SOCKET_DIR
        set -gx OPENCLAW_TMUX_SOCKET_DIR $CLAWDBOT_TMUX_SOCKET_DIR
    end
    set -e CLAWDBOT_TMUX_SOCKET_DIR
end

# ------------------------------------------------------------------------------
# Runtime manager (mise)
# ------------------------------------------------------------------------------
# Mise is now the primary runtime manager for Node and other toolchains.
# Keep legacy nvm installed on disk for emergency/manual access only, but do not
# let it manage PATH or shell startup anymore.
if test -x /home/jay/.local/bin/mise
    /home/jay/.local/bin/mise activate fish | source
end

# Remove stale legacy nvm bins from PATH now that mise owns runtime activation.
if set -q PATH
    set -l cleaned_path
    for p in $PATH
        if string match -qr ^/home/jay/\.local/share/nvm/v[^/]+/bin -- $p
            continue
        end
        if string match -qr ^/home/jay/\.nvm/current/bin -- $p
            continue
        end
        if string match -qr ^/home/jay/\.nvm/versions/node/[^/]+/bin -- $p
            continue
        end
        set cleaned_path $cleaned_path $p
    end
    set -gx PATH $cleaned_path
end

# Alias for neovim
alias v='nvim'

# Docker configuration
set -x DOCKER_BUILDKIT 1

# Environment variables
set -gx EDITOR nvim
if string match -qi "*microsoft*" (uname -r)
    set -gx BROWSER $HOME/.local/bin/google-chrome-wsl
else
    set -gx BROWSER wslview
end
set -gx GIT_EDITOR $EDITOR
set -gx COLORTERM truecolor
set -gx fish_prompt_pwd_dir_length 0

# Clockify Integration Environment Variables
set -x CLOCKIFY_API_KEY MTNiMDBhMjMtNTc3ZC00NTYwLWE3NzktMDQ4MWE0NzQ1Njhh
set -x CLOCKIFY_WORKSPACE_ID 5df7015a90e9290547d5fb16
set -x CLOCKIFY_USER_ID 60eb2b5a2a469042b6b55517
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

# ------------------------------------------------------------------------------
# Repo-aware Linear key routing + OpenCode guardrails
# ------------------------------------------------------------------------------
function __expected_linear_team_for_pwd --description 'Map current path to expected Linear team key'
    set -l cwd "$PWD"
    if string match -qr '^/home/jay/code/AET_TaskOps($|/)' -- "$cwd"
        echo AET
        return 0
    end
    if string match -qr '^/home/jay/code/(aet-webui|AET_WebUI)($|/)' -- "$cwd"
        echo AET
        return 0
    end
    if string match -qr '^/home/jay/code/AET_BizWiz($|/)' -- "$cwd"
        echo AET
        return 0
    end
    if string match -qr '^/home/jay/code/(AET_TaskOps|AET_KB4|AET_RedOps|AET_nFlex|AET_nFlex-deps-upgrade)($|/)' -- "$cwd"
        echo AET
        return 0
    end
    if string match -qr '^/home/jay/code/EH_team(_live)?($|/)' -- "$cwd"
        echo EH
        return 0
    end
    if string match -qr '^/home/jay/code/mission[Cc]ontrol($|/)' -- "$cwd"
        echo EH
        return 0
    end
    if string match -qr '^/home/jay/code/(seekakey|SeekaKey)($|/)' -- "$cwd"
        echo SEEK
        return 0
    end
    echo NONE
end

function __set_linear_key_for_pwd --description 'Set LINEAR_API_KEY based on repository path'
    set -l cwd "$PWD"
    if string match -qr '^/home/jay/code/(aet-webui|AET_WebUI)($|/)' -- "$cwd"
        if set -q LINEAR_API_KEY_AET_WEBUI
            set -gx LINEAR_API_KEY "$LINEAR_API_KEY_AET_WEBUI"
        else
            set -e LINEAR_API_KEY
        end
        return 0
    end
    if string match -qr '^/home/jay/code/AET_BizWiz($|/)' -- "$cwd"
        if set -q LINEAR_API_KEY_AET_BIZWIZ
            set -gx LINEAR_API_KEY "$LINEAR_API_KEY_AET_BIZWIZ"
        else
            set -e LINEAR_API_KEY
        end
        return 0
    end
    if string match -qr '^/home/jay/code/mission[Cc]ontrol($|/)' -- "$cwd"
        if set -q LINEAR_API_KEY_EH_WEBUI
            set -gx LINEAR_API_KEY "$LINEAR_API_KEY_EH_WEBUI"
        else
            set -e LINEAR_API_KEY
        end
        return 0
    end

    set -l team (__expected_linear_team_for_pwd)
    switch $team
        case AET
            if set -q LINEAR_API_KEY_AET
                set -gx LINEAR_API_KEY "$LINEAR_API_KEY_AET"
            else
                set -e LINEAR_API_KEY
            end
        case EH
            if set -q LINEAR_API_KEY_EH
                set -gx LINEAR_API_KEY "$LINEAR_API_KEY_EH"
            else
                set -e LINEAR_API_KEY
            end
        case SEEK
            if set -q LINEAR_API_KEY_SEEK
                set -gx LINEAR_API_KEY "$LINEAR_API_KEY_SEEK"
            else
                set -e LINEAR_API_KEY
            end
        case NONE '*'
            set -e LINEAR_API_KEY
    end
end

function __linear_key_preflight --description 'Verify active LINEAR_API_KEY matches expected team for this repo'
    set -l expected (__expected_linear_team_for_pwd)

    # Unmapped folders are allowed: run OpenCode without Linear binding.
    if test "$expected" = "NONE"
        return 0
    end

    if not set -q LINEAR_API_KEY
        echo "[oc-guard] BLOCKED_CONTEXT: expected team $expected but LINEAR_API_KEY is not set"
        return 1
    end

    set -l q '{"query":"query { teams(first:10) { nodes { key } } }"}'
    set -l found (curl -s https://api.linear.app/graphql \
        -H 'Content-Type: application/json' \
        -H "Authorization: $LINEAR_API_KEY" \
        --data-binary "$q" | jq -r '.data.teams.nodes[].key' | string join ',')

    if test -z "$found"
        echo "[oc-guard] BLOCKED_CONTEXT: unable to resolve Linear workspace for current key"
        return 1
    end

    set -l resolved_teams (string split ',' -- "$found")
    if not contains -- "$expected" $resolved_teams
        echo "[oc-guard] BLOCKED_CONTEXT: expected Linear team $expected but key resolves to [$found]"
        return 1
    end

    return 0
end

function __auto_set_linear_key --on-variable PWD --description 'Auto-switch LINEAR_API_KEY on directory change'
    __set_linear_key_for_pwd >/dev/null 2>&1
end

function oc --description 'Open OpenCode with repo-aware Linear key guardrails'
    __set_linear_key_for_pwd

    set -l expected (__expected_linear_team_for_pwd)
    if test "$expected" = "NONE"
        echo "[oc-guard] INFO: unmapped path - launching OpenCode without Linear workspace binding"
        if test (count $argv) -eq 0
            command opencode .
        else
            command opencode $argv
        end
        return $status
    end

    if not __linear_key_preflight
        return 1
    end

    if test (count $argv) -eq 0
        command opencode .
    else
        command opencode $argv
    end
end

# Ensure key is set for initial shell cwd
__set_linear_key_for_pwd >/dev/null 2>&1

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
        exec tmux -f "$HOME/.config/tmux/tmux.conf" new-session -A -s main
    end
end
set -x OPENCODE_ENABLE_EXPERIMENTAL_MODELS true
set -x OPENCODE_EXPERIMENTAL_DISABLE_COPY_ON_SELECT true
set -x OPENCODE_EXPERIMENTAL_ICON_DISCOVERY true
