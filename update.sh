#!/usr/bin/env bash
set -eEuo pipefail
set -x

main() {
    export host="$1"
    export hostname="$host"
    export conn="$host"

    scp ./remote-*.sh ./configuration.nix "$conn:~"
    ssh "$conn" ./remote-cache.sh "$hostname"
    ssh "$conn" ./remote-configuration.sh "$hostname"

    echo "Comparing with existing config:"
    if ssh "$conn" diff --color -C 3 /etc/nixos/configuration.nix ./configuration.nix ; then
        return 0
    fi

    read -p "Accept and execute nixos-rebuild? y/n : " yn
    [[ "$yn" != "y" ]] && return 0

    ssh "$conn" sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
    ssh "$conn" sudo nix-channel --update
    ssh "$conn" sudo cp ./configuration.nix /etc/nixos/
    ssh "$conn" sudo nixos-rebuild switch
}

main "$@"
