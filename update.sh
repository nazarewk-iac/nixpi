#!/usr/bin/env bash
set -eEuo pipefail
set -x

main() {
    . .venv/bin/activate
    ansible-playbook ansible/deploy.yml
}

main "$@"
