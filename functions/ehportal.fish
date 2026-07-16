function ehportal
    set -l raw (ssh -o ConnectTimeout=10 jay@100.115.181.93 "bash -lc 'sudo -u node -H bash -lc \"source /home/node/.nvm/nvm.sh >/dev/null 2>&1 || true; openclaw dashboard --no-open\"'" 2>/dev/null)
    set -l line (string match -r '^Dashboard URL: .*' -- $raw)
    set -l url (string replace 'Dashboard URL: http://127.0.0.1:18789/' 'https://eh-core.taild4ff67.ts.net/' -- $line)
    set -l token (ssh -o ConnectTimeout=10 jay@100.115.181.93 "sudo -u node -H node -e 'const fs=require(\"fs\"); const j=JSON.parse(fs.readFileSync(\"/home/node/.openclaw/secrets.local.json\",\"utf8\")); const token=j.gateway&&j.gateway.auth&&j.gateway.auth.token; if(!token) process.exit(2); process.stdout.write(token);'" 2>/dev/null)
    if test -z "$url"
        echo "Failed to fetch dashboard URL from eh-core"
        return 1
    end
    if test -z "$token"
        echo "Failed to fetch gateway token from eh-core"
        return 1
    end
    set url "$url#token="(string escape --style=url -- $token)
    powershell.exe -NoProfile -Command "Start-Process '$url'"
end
