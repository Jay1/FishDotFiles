function bup
    # Icons: set -U BUP_ICONS emoji | text
    set -l style (set -q BUP_ICONS; and echo $BUP_ICONS; or echo text)
    set -l ok
    set -l err
    set -l run
    switch $style
        case emoji
            set ok "✅"
            set err "❌"
            set run "🔄"
        case text
            set ok "✓"
            set err "✗"
            set run "↻"
    end

    argparse -n bup \
        h/help l/list n/dry-run c/cleanup d/doctor \
        F/formula K/cask g/greedy q/quiet -- $argv
    or return

    if set -q _flag_help
        echo "bup [-l] [-n] [-c] [-d] [-F|-K] [-g] [-q] [pkgs...]"
        return
    end

    set -l brew (command -v brew)
    test -x $brew; or begin
        echo "$err brew not found"
        return 127
    end

    set -l start (date +%s)
    set -l QUIET 0
    set -q _flag_q; and set QUIET 1
    set -l GREEDY
    set -q _flag_g; and set GREEDY --greedy

    test $QUIET -eq 1; or echo "$run Updating taps…"
    $brew update --quiet >/dev/null 2>&1; or begin
        echo "$err Update failed"
        return 1
    end

    # Detect cask support (macOS) and skip on Linux/WSL
    set -l HAS_CASK 0
    $brew list --cask >/dev/null 2>&1; and set HAS_CASK 1

    set -l only_formula (set -q _flag_F; and echo 1; or echo 0)
    set -l only_cask (set -q _flag_K; and echo 1; or echo 0)

    set -l o_f ($brew outdated --formula --quiet 2>/dev/null)
    set -l o_c ""
    if test $HAS_CASK -eq 1 -a $only_formula -eq 0
        set o_c ($brew outdated --cask $GREEDY --quiet 2>/dev/null)
    end

    if set -q _flag_list
        test -n "$o_f"; and echo "Formulae:"; and printf "%s\n" $o_f
        test -n "$o_c"; and echo "Casks:"; and printf "%s\n" $o_c
        test -z "$o_f$o_c"; and echo "$ok Already up-to-date"
        return
    end

    if set -q _flag_dry_run
        if test -n "$o_f$o_c"
            echo "$ok dry-run: Would upgrade:"
            printf "%s\n" $o_f $o_c
        else
            echo "$ok dry-run: Nothing to action"
        end
        return
    end

    if test (count $argv) -gt 0
        test $QUIET -eq 1; or echo "$run Upgrading: "(string join " " $argv)
        env HOMEBREW_NO_AUTO_UPDATE=1 $brew upgrade $argv; or begin
            echo "$err Upgrade failed"
            return 1
        end
    else
        if test -n "$o_f"
            test $QUIET -eq 1; or echo "$run Upgrading formulae…"
            env HOMEBREW_NO_AUTO_UPDATE=1 $brew upgrade --formula; or begin
                echo "$err Formula upgrade failed"
                return 1
            end
        end
        if test -n "$o_c"
            test $QUIET -eq 1; or echo "$run Upgrading casks…"
            env HOMEBREW_NO_AUTO_UPDATE=1 $brew upgrade --cask $GREEDY; or begin
                echo "$err Cask upgrade failed"
                return 1
            end
        end
        test -z "$o_f$o_c"; and echo "$ok Already up-to-date"
    end

    if set -q _flag_cleanup
        set -l would ($brew cleanup -n | string match -r '(^| )((Free|Would).*)')
        $brew cleanup -s
        test -n "$would"; and echo "$ok Cleanup: $would"; or echo "$ok Cleanup"
        $brew autoremove >/dev/null 2>&1
    end

    set -l dur (math (date +%s) - $start)
    test $QUIET -eq 1; or echo "$ok Done in $dur s"
end
