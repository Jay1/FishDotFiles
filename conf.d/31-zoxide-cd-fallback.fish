# Added by EH on 2026-04-02.
# Keep normal `cd` behavior, but if the argument is a simple token that does
# not exist as a literal path, fall back to zoxide query.
# Examples:
#   cd cld      -> /home/jay/code/AET_CLD   (if zoxide has learned it)
#   cd taskops  -> /home/jay/code/AET_TaskOps
# Normal paths still behave exactly like normal cd.
if not functions -q __eh_builtin_cd
    functions -c cd __eh_builtin_cd
end

function cd --wraps cd --description 'cd with zoxide fallback for simple unmatched tokens'
    if test (count $argv) -eq 0
        __eh_builtin_cd
        return $status
    end

    if test (count $argv) -gt 1
        __eh_builtin_cd $argv
        return $status
    end

    set -l target $argv[1]

    switch $target
        case '-' '~' '.' '..' '...'
            __eh_builtin_cd $target
            return $status
    end

    if string match -qr '(^/|^\.|/)' -- $target
        __eh_builtin_cd $target
        return $status
    end

    if test -e $target
        __eh_builtin_cd $target
        return $status
    end

    if command -sq zoxide
        set -l resolved (zoxide query --exclude $PWD -- $target 2>/dev/null)
        if test -n "$resolved"
            __eh_builtin_cd "$resolved"
            return $status
        end
    end

    __eh_builtin_cd $target
end
