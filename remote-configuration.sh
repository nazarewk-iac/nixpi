#!/usr/bin/env bash
set -eEuo pipefail
set -x

main() {
    local hostname="$1"
    local file="configuration.nix"
    local ip="$(ip -4 a s dev eth0 | grep -o 'inet .*/' | sed 's#inet \(.*\)/#\1#g')"

    sed -i.bkp \
        -e "s/nixpi-hostname/$hostname/g" \
        -e "s/nixpi-ip/$ip/g" \
        -e "s#http://$ip:5000 ##g" \
        "$file"

    echo 'Modified:'
    diff --color -C 3 "$file"{,.bkp} || true
}

main "$@"
