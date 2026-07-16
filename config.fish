# Core environment
set -g async_prompt_enable 0
fish_add_path /usr/local/bin $HOME/.local/bin

if test -d $HOME/.bun/bin
    fish_add_path -m $HOME/.bun/bin
end

if test -f /home/linuxbrew/.linuxbrew/bin/brew
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
end

# OpenClaw compatibility
if set -q CLAWDBOT_TMUX_SOCKET_DIR
    if not set -q OPENCLAW_TMUX_SOCKET_DIR
        set -gx OPENCLAW_TMUX_SOCKET_DIR $CLAWDBOT_TMUX_SOCKET_DIR
    end
    set -e CLAWDBOT_TMUX_SOCKET_DIR
end

# Toolchains
if test -x /home/jay/.local/bin/mise
    /home/jay/.local/bin/mise activate fish | source
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

alias v='nvim'

set -gx DOCKER_BUILDKIT 1
set -gx EDITOR nvim
if string match -qi "*microsoft*" (uname -r)
    set -gx BROWSER $HOME/.local/bin/google-chrome-wsl
else
    set -gx BROWSER wslview
end
set -gx GIT_EDITOR $EDITOR
set -gx COLORTERM truecolor
set -g fish_prompt_pwd_dir_length 0
set -g fish_greeting "Welcome back, Jay"

if command -q vivid
    set -gx LS_COLORS (vivid generate snazzy)
end

# Platform
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

# Repo-aware Linear key routing + OpenCode guardrails
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
    if string match -qr '^/home/jay/code/(AET_nFlex|AET_nFlex-deps-upgrade)($|/)' -- "$cwd"
        echo AET
        return 0
    end
    if string match -qr '^/home/jay/\.local/state/jcode/worktrees/AET_nFlex/[^/]+($|/)' -- "$cwd"
        echo AET
        return 0
    end
    if string match -qr '^/home/jay/code/(AET_TaskOps|AET_KB4|AET_RedOps)($|/)' -- "$cwd"
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
    if string match -qr '^/home/jay/code/(AET_nFlex|AET_nFlex-deps-upgrade)($|/)' -- "$cwd"
        if set -q LINEAR_API_KEY_AET_NFLEX
            set -gx LINEAR_API_KEY "$LINEAR_API_KEY_AET_NFLEX"
        else
            set -e LINEAR_API_KEY
        end
        return 0
    end
    if string match -qr '^/home/jay/\.local/state/jcode/worktrees/AET_nFlex/[^/]+($|/)' -- "$cwd"
        if set -q LINEAR_API_KEY_AET_NFLEX
            set -gx LINEAR_API_KEY "$LINEAR_API_KEY_AET_NFLEX"
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

__set_linear_key_for_pwd >/dev/null 2>&1

# Interactive integrations
if status is-interactive
    if test -f ~/.config/openstack/atmosphere-openrc.fish
        source ~/.config/openstack/atmosphere-openrc.fish >/dev/null 2>&1
    end

    if type -q zoxide
        zoxide init fish | source
    end

    # Keep Starship last in this block.
    if type -q starship
        starship init fish | source
    end
end

if status is-interactive
    and not set -q TMUX
    and set -q SSH_CONNECTION
    if type -q tmux
        exec tmux -f "$HOME/.config/tmux/tmux.conf" new-session -A -s main
    end
end

set -gx OPENCODE_ENABLE_EXPERIMENTAL_MODELS true
set -gx OPENCODE_EXPERIMENTAL_DISABLE_COPY_ON_SELECT true
set -gx OPENCODE_EXPERIMENTAL_ICON_DISCOVERY true
