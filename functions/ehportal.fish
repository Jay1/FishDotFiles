function ehportal
    set -l raw (ssh -o ConnectTimeout=10 jay@100.115.181.93 "bash -lc 'sudo -u node -H bash -lc \"source /home/node/.nvm/nvm.sh >/dev/null 2>&1 || true; openclaw dashboard --no-open\"'" 2>/dev/null)
    set -l line (string match -r '^Dashboard URL: .*' -- $raw)
    set -l url (string replace 'Dashboard URL: http://127.0.0.1:18789/' 'https://eh-core.taild4ff67.ts.net/' -- $line)
    if test -z "$url"
        echo "Failed to fetch dashboard URL from eh-core"
        return 1
    end
    powershell.exe -NoProfile -Command "Start-Process '$url'"
end
