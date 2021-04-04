#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

usage() {
    echo "Usage: $0 TEST_SCRIPT [STARTING_TEST_NUMBER]" >&2
    exit 1
}

if (( $# < 1 )); then
    usage
fi

TEST_SCRIPT=$1
STARTING_TEST_NUMBER=${2:-1}

PREVIOUS_TEST_NUMBER=${STARTING_TEST_NUMBER}

while true; do
    TEST_NUMBER=$(( PREVIOUS_TEST_NUMBER + 1 ))
    if (( (TEST_NUMBER - 1) % 4 == 2 )); then
        TEST_NUMBER=$(( PREVIOUS_TEST_NUMBER + 2 ))
    fi

    "${SCRIPT_DIR}/diff_test.sh" "${TEST_SCRIPT}" "${PREVIOUS_TEST_NUMBER}" "${TEST_NUMBER}"

    read -r -p 'Press [Enter] to continue...'
    PREVIOUS_TEST_NUMBER=${TEST_NUMBER}
done
