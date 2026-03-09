function __oc911 --description 'Recover OpenClaw gateway and wait for RPC-ready health'
    set -l service_name openclaw-gateway.service
    set -l port 18789
    set -l probe_log /tmp/oc911-probe.log
    set -l gateway_log /tmp/openclaw-gateway-manual.out

    function __oc911_probe_ok --no-scope-shadowing
        openclaw gateway probe >$probe_log 2>&1
        return $status
    end

    function __oc911_listener_line --no-scope-shadowing
        ss -ltnp 2>/dev/null | rg ":$port\\b" | head -n 1
    end

    function __oc911_wait_ready --no-scope-shadowing
        set -l tries 0
        while test $tries -lt 25
            if __oc911_probe_ok
                return 0
            end
            sleep 1
            set tries (math $tries + 1)
        end
        return 1
    end

    echo "🦞 oc911: checking gateway health..."
    if __oc911_probe_ok
        echo "✅ Gateway already healthy (RPC-ready)."
        cat $probe_log
        functions -e __oc911_probe_ok __oc911_listener_line __oc911_wait_ready
        return 0
    end

    set -l using_systemd false
    if command -q systemctl
        if systemctl is-system-running >/dev/null 2>&1
            if systemctl cat $service_name >/dev/null 2>&1
                set using_systemd true
            end
        end
    end

    if test "$using_systemd" = true
        set -l sudo_cmd
        if test (id -u) -ne 0
            if not command -q sudo
                echo "❌ sudo is required to recover $service_name from this shell."
                functions -e __oc911_probe_ok __oc911_listener_line __oc911_wait_ready
                return 1
            end
            set sudo_cmd sudo
        end

        echo "⚠️  oc911: recovering systemd-managed gateway service"
        if $sudo_cmd systemctl restart $service_name
            if __oc911_wait_ready
                echo "✅ Gateway recovered via systemd and is RPC-ready."
                cat $probe_log
                functions -e __oc911_probe_ok __oc911_listener_line __oc911_wait_ready
                return 0
            end

            echo "⚠️  systemd restart completed but RPC is still not healthy; falling back to manual recovery."
            $sudo_cmd systemctl status $service_name --no-pager --lines=20
            echo "--- probe output ---"
            cat $probe_log
        else
            echo "⚠️  systemd restart path failed; falling back to manual recovery."
        end
    end

    echo "⚠️  oc911: recovering manually-managed gateway process (WSL/local mode)"

    set -l pids (pgrep -f '(^|/)openclaw-gateway($| )|openclaw gateway run' | string trim)
    if test -n "$pids"
        echo "Stopping existing gateway PID(s): $pids"
        for pid in $pids
            kill $pid 2>/dev/null
        end
        sleep 1
        for pid in $pids
            if kill -0 $pid 2>/dev/null
                kill -9 $pid 2>/dev/null
            end
        end
    end

    set -l listener_line (__oc911_listener_line)
    if test -n "$listener_line"
        set -l listener_pid (echo $listener_line | sed -nE 's/.*pid=([0-9]+).*/\1/p' | head -n 1)
        if test -n "$listener_pid"
            set -l listener_cmd (ps -p $listener_pid -o cmd= 2>/dev/null | string trim)
            if string match -q '*openclaw*' "$listener_cmd"
                echo "Clearing stale OpenClaw listener on :$port (pid $listener_pid)"
                kill -9 $listener_pid 2>/dev/null
                sleep 1
            else
                echo "❌ Port $port is occupied by a non-OpenClaw process: $listener_cmd"
                echo "Aborting to avoid killing the wrong thing."
                functions -e __oc911_probe_ok __oc911_listener_line __oc911_wait_ready
                return 1
            end
        end
    end

    echo "Starting fresh gateway..."
    nohup openclaw gateway run --force >$gateway_log 2>&1 &
    disown

    if not __oc911_wait_ready
        echo "❌ Gateway start attempted, but RPC is still not healthy."
        echo "--- probe output ---"
        cat $probe_log
        echo "--- gateway log tail ---"
        tail -n 80 $gateway_log 2>/dev/null
        echo "--- process snapshot ---"
        ps -ef | rg 'openclaw-gateway|openclaw gateway run'
        functions -e __oc911_probe_ok __oc911_listener_line __oc911_wait_ready
        return 1
    end

    echo "✅ Gateway recovered and is RPC-ready."
    cat $probe_log
    functions -e __oc911_probe_ok __oc911_listener_line __oc911_wait_ready
    return 0
end
