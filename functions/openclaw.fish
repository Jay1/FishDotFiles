function openclaw --description 'Run openclaw with the latest Node via nvm'
    set -l openclaw_bin /home/jay/.bun/bin/openclaw

    if not test -x $openclaw_bin
        set openclaw_bin (command -s openclaw)
        if test -z "$openclaw_bin"
            echo "openclaw: command not found in PATH" >&2
            return 1
        end
    end

    set --erase --global nvm_current_version 2>/dev/null
    set --erase --universal nvm_current_version 2>/dev/null

    if not functions -q nvm
        if test -f $HOME/.config/fish/conf.d/nvm.fish
            source $HOME/.config/fish/conf.d/nvm.fish
        end
    end

    if functions -q nvm_use_latest_installed
        nvm_use_latest_installed >/dev/null 2>&1
    else if functions -q nvm
        nvm use --silent default >/dev/null 2>&1
    end

    if test (count $argv) -ge 2
        if test "$argv[1]" = gateway
            and test "$argv[2]" = status
            if functions -q openclaw-gateway-status
                openclaw-gateway-status
                return $status
            end
        end
    end

    command $openclaw_bin $argv
end
