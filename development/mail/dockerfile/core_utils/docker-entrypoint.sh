#! /bin/sh
set -e


function wait_for_mailcore_ready() {
    if [[ -z "${MAILMAN_CORE_ENDPOINT}" ]]; then
        echo "MAILMAN_CORE_ENDPOINT is not defined. exit none zero."
        exit 1
    fi
    echo "accessing mailcore endpoints ${MAILMAN_CORE_ENDPOINT}"
    while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' $MAILMAN_CORE_ENDPOINT)" != "401" ]]; do
     sleep 1;
     echo "retrying: accessing mailcore endpoints ${MAILMAN_CORE_ENDPOINT}"
    done
}

wait_for_mailcore_ready

exec $@
