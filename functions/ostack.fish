function ostack
    switch $argv[1]
        case auth
            # Source the OpenRC file and verify authentication
            source ~/.config/openstack/atmosphere-openrc.fish
            and openstack token issue >/dev/null 2>&1
            and echo "Successfully authenticated to OpenStack"
            or echo "Authentication failed"

        case status
            # Check authentication status
            openstack token issue -f value -c expires

        case resources
            # Quick overview of resources
            echo "Checking available resources..."
            echo "Servers:"
            openstack server list
            echo -e "\nNetworks:"
            openstack network list

        case "*"
            echo "Usage: ostack <command>"
            echo "Commands:"
            echo "  auth      - Authenticate to OpenStack"
            echo "  status    - Check authentication status"
            echo "  resources - List basic resources"
    end
end
