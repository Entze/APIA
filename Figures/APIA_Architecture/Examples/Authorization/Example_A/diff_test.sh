#!/usr/bin/env bash

if (( $# != 2 )); then
    echo "Usage: $0 PREVIOUS_TEST_NUMBER NEW_TEST_NUMBER" >&2
    exit 1
fi
PREVIOUS_TEST_NUMBER=$1
NEW_TEST_NUMBER=$2

PREVIOUS_TEST_FILE=$(mktemp "test_${PREVIOUS_TEST_NUMBER}.XXXXXXXXXX")
NEW_TEST_FILE=$(mktemp "test_${NEW_TEST_NUMBER}.XXXXXXXXXX")

./test.sh "${PREVIOUS_TEST_NUMBER}" | sed 's/^/  /' > "${PREVIOUS_TEST_FILE}"
./test.sh "${NEW_TEST_NUMBER}" | sed 's/^/  /' > "${NEW_TEST_FILE}"
git --no-pager diff --no-index "${PREVIOUS_TEST_FILE}" "${NEW_TEST_FILE}"

rm "${PREVIOUS_TEST_FILE}" "${NEW_TEST_FILE}"
