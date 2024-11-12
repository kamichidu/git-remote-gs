#!/bin/bash

__urlencode() {
    jq -Rr @uri <<<"${1}"
}

__log_pipe() {
    local line
    while read line; do
        if [[ -z "${GIT_GS_TRACE:-}" ]]; then
            continue
        fi
        echo "*** ${line}" 1>&2
    done
}

__log() {
    if [[ -z "${GIT_GS_TRACE:-}" ]]; then
        return 0
    fi
    echo "*** ${*}" 1>&2
}

__state-pull() {
    gcloud storage rsync "${__url}" "${__tmpdir}" \
        --recursive \
        --delete-unmatched-destination-objects \
        2>&1 | __log_pipe
}

__state-push() {
    gcloud storage rsync "${__tmpdir}" "${__url}" \
        --recursive \
        --delete-unmatched-destination-objects \
        2>&1 | __log_pipe
}
