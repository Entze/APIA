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
    example_s.lp

    Departments/domain_encoding.lp
    Departments/example_s.lp
    Departments/instance.lp

    Meetings/domain_encoding.lp
    Meetings/example_s.lp
    Meetings/instance.lp

    Movement/domain_encoding.lp
    Movement/example_s.lp
    Movement/instance.lp

    Objects/domain_encoding.lp
    Objects/example_s.lp
    Objects/instance.lp
)

../../Implementation/test.sh "${TEST_NUM}" "${MAX_TIMESTEP:-12}" "${FILES[@]}"
