#!/usr/bin/env bash
set -eEuo pipefail
set -x

main() {
    cache_keys "$1"
}

cache_keys() {
    local hostname="$1"
    local idx=0
    local name="$hostname-$idx"
    local priv="$name-priv-key.pem"
    local pub="$name-pub-key.pem"
    [[ ! -f "/var/$priv" ]] || return 0
    pushd /var
    if [[ ! -f "$priv" || ! -f "$pub" ]] ; then
        sudo nix-store --generate-binary-cache-key "$name" "$priv" "$pub"
    fi

    sudo chown nix-serve "$priv" "$pub"
    sudo chmod 600 "$priv"
    sudo chmod 444 "$pub"
    popd
}

main "$@"
