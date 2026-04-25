# Added by EH on 2026-04-02.
# zoxide = smart directory jumping for Fish.
# Usage:
#   z cld   -> jump to a remembered directory matching "cld"
#   zi cld  -> interactive picker when multiple matches exist
#   Alt-C   -> fuzzy-pick a directory using fzf bindings
set -l __eh_zoxide_bin /home/linuxbrew/.linuxbrew/bin/zoxide
if test -x $__eh_zoxide_bin
    $__eh_zoxide_bin init fish | source
else if command -sq zoxide
    zoxide init fish | source
end
set -e __eh_zoxide_bin
