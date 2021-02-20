#!/usr/bin/env bash

if (( $# == 1 )); then
    TEST_NUM=$1
else
    if tty -s; then
        read -r -p 'Test number: ' TEST_NUM
    else
        echo "Usage: $0 TEST_NUM" >&2
        exit 1
    fi
fi

../../../test.sh "${TEST_NUM}" domain_encoding.lp instance.lp ../sanity_checks.lp tests.lp
