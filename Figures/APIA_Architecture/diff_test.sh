#!/usr/bin/env bash

usage() {
    echo "Usage: $0 TEST_SCRIPT PREVIOUS_TEST_NUMBER NEW_TEST_NUMBER" >&2
    exit 1
}

if (( $# < 1 )); then
    usage
fi

TEST_SCRIPT=$1

if (( $# == 3 )); then
    PREVIOUS_TEST_NUMBER=$2
    NEW_TEST_NUMBER=$3
else
    if tty -s; then
        read -r -p 'Previous test number: ' PREVIOUS_TEST_NUMBER
        read -r -p 'New test number: ' NEW_TEST_NUMBER
    else
        usage
    fi
fi

PREVIOUS_TEST_FILE=$(mktemp "/tmp/apia_test_${PREVIOUS_TEST_NUMBER}.XXXXXXXXXX")
NEW_TEST_FILE=$(mktemp "/tmp/apia_test_${NEW_TEST_NUMBER}.XXXXXXXXXX")

"${TEST_SCRIPT}" "${PREVIOUS_TEST_NUMBER}" | sed 's/^/  /' > "${PREVIOUS_TEST_FILE}"
"${TEST_SCRIPT}" "${NEW_TEST_NUMBER}" | sed 's/^/  /' > "${NEW_TEST_FILE}"
git --no-pager diff --unified=10 --no-index "${PREVIOUS_TEST_FILE}" "${NEW_TEST_FILE}"

echo "Previous test: ${PREVIOUS_TEST_NUMBER} (Step $(( (PREVIOUS_TEST_NUMBER - 1) % 4 + 1)))" >&2
echo "New test: ${NEW_TEST_NUMBER} (Step $(( (NEW_TEST_NUMBER - 1) % 4 + 1)))" >&2
rm "${PREVIOUS_TEST_FILE}" "${NEW_TEST_FILE}"
