#!/usr/bin/env bash

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

../../../test.sh "${TEST_NUM}" "${MAX_TIMESTEP:-12}" domain_encoding.lp instance.lp ../sanity_checks.lp tests.lp
