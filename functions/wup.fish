function wup --description 'Update WSL system packages, Homebrew, and optional dev tools'
    argparse -n wup h/help n/dry-run c/cleanup t/tools q/quiet -- $argv
    or return

    if set -q _flag_help
        echo "wup [-n|--dry-run] [-c|--cleanup] [-t|--tools] [-q|--quiet]"
        echo "  default: apt update/upgrade, Homebrew bup, snap refresh when available"
        echo "  --tools: also update mise-managed tools, rustup, and npm globals"
        echo "  --cleanup: run apt autoremove/autoclean and brew cleanup"
        return
    end

    set -l start (date +%s)
    set -l quiet 0
    set -q _flag_q; and set quiet 1
    set -l dry_run 0
    set -q _flag_n; and set dry_run 1

    set -l ok "✓"
    set -l err "✗"
    set -l run "↻"

    function __wup_note --inherit-variable quiet
        test $quiet -eq 1; or echo $argv
    end

    function __wup_run --inherit-variable err
        echo "$argv"
        command $argv
        set -l status_code $status
        if test $status_code -ne 0
            echo "$err failed: $argv"
            return $status_code
        end
    end

    if test $dry_run -eq 1
        __wup_note "$run apt upgradable packages"
        apt list --upgradable 2>/dev/null

        if command -q brew
            __wup_note "$run Homebrew outdated packages"
            brew outdated
        end

        if command -q snap
            __wup_note "$run snap refresh check"
            snap refresh --list
        end

        if set -q _flag_tools
            if command -q mise
                __wup_note "$run mise outdated tools"
                mise outdated
            end
            if command -q rustup
                __wup_note "$run rustup toolchains"
                rustup check
            end
            if command -q npm
                __wup_note "$run npm global outdated packages"
                npm outdated -g --depth=0
            end
        end

        return
    end

    if not command -q sudo
        echo "$err sudo not found"
        return 127
    end

    __wup_note "$run refreshing sudo"
    sudo -v; or return

    __wup_note "$run apt update"
    sudo apt-get update; or return

    __wup_note "$run apt upgrade"
    sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y; or return

    if command -q brew
        __wup_note "$run Homebrew bup"
        if functions -q bup
            bup; or return
        else
            brew update; and brew upgrade; or return
        end
    end

    if command -q snap
        __wup_note "$run snap refresh"
        sudo snap refresh; or return
    end

    if set -q _flag_tools
        if command -q mise
            __wup_note "$run mise upgrade"
            mise upgrade; or return
        end
        if command -q rustup
            __wup_note "$run rustup update"
            rustup update; or return
        end
        if command -q npm
            __wup_note "$run npm global update"
            npm update -g; or return
        end
    end

    if set -q _flag_cleanup
        __wup_note "$run apt cleanup"
        sudo apt-get autoremove -y; or return
        sudo apt-get autoclean; or return

        if command -q brew
            __wup_note "$run Homebrew cleanup"
            brew cleanup -s; or return
            brew autoremove; or return
        end
    end

    set -l dur (math (date +%s) - $start)
    test $quiet -eq 1; or echo "$ok WSL update complete in $dur s"
end
