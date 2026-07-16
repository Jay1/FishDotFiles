function ostack
    set -l openrc ~/.config/openstack/atmosphere-openrc.fish

    function __ostack_load_openrc --inherit-variable openrc
        if not test -f $openrc
            echo "Missing OpenStack RC file: $openrc" >&2
            return 1
        end

        source $openrc >/dev/null 2>&1
    end

    function __ostack_require_cli
        if not command -q openstack
            echo "Missing OpenStack CLI: install python-openstackclient or add openstack to PATH" >&2
            return 1
        end
    end

    switch $argv[1]
        case auth
            # Source the OpenRC file and verify authentication
            __ostack_load_openrc
            and __ostack_require_cli
            and openstack token issue -f value -c expires
            and echo "Successfully authenticated to OpenStack"
            or echo "Authentication failed"

        case status
            # Check authentication status
            __ostack_load_openrc
            and __ostack_require_cli
            and echo "Token expires:"
            and openstack token issue -f value -c expires

        case env
            __ostack_load_openrc
            and env | string match "OS_*" | sort

        case login
            ostack auth

        case remote-login
            __ostack_load_openrc
            and __ostack_require_cli
            or return 1

            set -lx BROWSER ~/.local/bin/ostack-print-url
            echo "Starting remote OpenStack SSO."
            echo "Use this from an SSH session with: ssh -L 9990:localhost:9990 ..."
            openstack token issue -f value -c expires
            and echo "Successfully authenticated to OpenStack"

        case projects
            __ostack_load_openrc
            and __ostack_require_cli
            and openstack project list

        case token
            __ostack_load_openrc
            and __ostack_require_cli
            openstack token issue -f value -c expires

        case resources
            # Quick overview of resources
            __ostack_load_openrc
            and __ostack_require_cli
            or return 1
            echo "Checking available resources..."
            echo "Servers:"
            openstack server list
            echo -e "\nNetworks:"
            openstack network list

        case "*"
            echo "Usage: ostack <command>"
            echo "Commands:"
            echo "  auth      - Authenticate to OpenStack"
            echo "  login     - Alias for auth"
            echo "  remote-login - Print SSO URL for SSH -L 9990 remote use"
            echo "  status    - Check authentication status"
            echo "  env       - Show loaded OS_* environment"
            echo "  projects  - List projects"
            echo "  token     - Print token expiry"
            echo "  resources - List basic resources"
    end
end
