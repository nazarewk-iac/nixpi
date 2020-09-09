#!/usr/bin/env bash
set -eEuo pipefail
set -x

main() {
    export host="$1"
    export hostname="$2"
    export user=nixos
    export conn="$user@$host"

    scp ./remote-*.sh ./configuration.nix "$conn:~"
    ssh "$conn" ./remote-cache.sh "$hostname"
    ssh "$conn" ./remote-configuration.sh "$hostname"

    ssh "$conn" sudo nixos-generate-config
    ssh "$conn" sudo cp ./configuration.nix /etc/nixos/
    read -p "Execute nixos-rebuild? y/n : " yn
    [[ "$yn" != "y" ]] && return 0
    ssh "$conn" sudo nixos-rebuild switch
}

main "$@"
