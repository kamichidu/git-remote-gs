#!/bin/bash

# See https://git-scm.com/docs/gitremote-helpers

__remote="${1}"
__url="${2:-}"

if [[ -z "${__url}" ]]; then
    __url="$(git remote get-url "${__remote}")"
fi

__tmpdir="$(dirname "$(mktemp --dry-run)")"
__tmpdir="${__tmpdir}/$(__urlencode "${__url}")"

__log <<EOF
args   = ${@}
remote = ${__remote}
url    = ${__url}
tmpdir = ${__tmpdir}
EOF

capabilities() {
    echo '*push'
    echo '*fetch'
    echo ''
}

list() {
    git ls-remote --quiet "${__tmpdir}" | sed -E 's|\s+| |g'
    echo ''
}

list-for-push() {
    git ls-remote --quiet --refs "${__tmpdir}" | sed -E 's|\s+| |g'
    echo ''
}

push() {
    local local_ref="$(awk -F ':' '{print $1}' <<<"${1}")"
    local remote_ref="$(awk -F ':' '{print $2}' <<<"${1}")"

    git push "${__tmpdir}" "${1}"

    echo "ok ${remote_ref}"
    echo ''
}

fetch() {
    local sha1="$(awk '{print $1}' <<<"${1}")"
    local name="$(awk '{print $1}' <<<"${1}")"

    git fetch "${__tmpdir}" "${sha1}" "${name}"

    echo ''
}

main() {
    __state-pull

    local push_buffer=()
    local command_line
    while read command_line; do
        if [[ -z "${command_line}" ]]; then
            break
        fi
        __log "command: ${command_line}"
        case "${command_line}" in
            'capabilities')   capabilities;;
            'list')           list;;
            'list for-push')  list-for-push;;
            'push'*)          push_buffer+=("${command_line}");;
            'fetch'*)         ${command_line};;
            *)
                exit 1
                ;;
        esac
    done

    local push_line
    for push_line in "${push_buffer[@]}"; do
        __log "${push_line}"
        ${push_line}
    done

    if [[ "${#push_buffer[@]}" > 0 ]]; then
        __state-push
    fi
}
main "${@}"
