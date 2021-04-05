#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if (( $# >= 1 )); then
    TEST_NUM=$1
    MAX_TIMESTEP=$2
else
    if tty -s; then
        read -r -p 'Test number: ' TEST_NUM
    else
        echo "Usage: $0 TEST_NUM MAX_TIMESTEP" >&2
        exit 1
    fi
fi

cd "${SCRIPT_DIR}" || exit 2

FILES=(
    domain_encoding.lp
    instance.lp
    ../sanity_checks.lp
    tests.lp
)

../../../Implementation/test.sh "${TEST_NUM}" "${MAX_TIMESTEP:-7}" "${FILES[@]}"
