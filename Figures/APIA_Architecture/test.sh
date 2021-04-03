#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if (( $# < 3 )); then
    echo "Usage: $0 TEST_NUM MAX_TIMESTEP FILE [...]" >&2
    exit 1
fi

TEST_NUM=$1
MAX_TIMESTEP=$2
shift 2
FILES=( "$@" )

# Set DEBUG to '', 'debug', or 'trace'

GLOBAL_FILES=(
    aaa_axioms.lp
    aia_theory_of_intentions.lp
    aia_history_rules.lp
    aia_intended_action_rules.lp
    aopl_authorization_compliance.lp
    aopl_obligation_compliance.lp
    general_axioms.lp
    apia_cr_prolog.lp
    apia_policy.lp
    apia_compliance_check.lp
    test.py
)

if [[ -n "${DEBUG}" ]]; then
    GLOBAL_FILES+=( apia_debugging_checks.lp )
else
    GLOBAL_FILES+=( show.lp )
fi

for GLOBAL_FILE in "${GLOBAL_FILES[@]}"; do
    RELATIVE_PATH=$(realpath --relative-to . "${SCRIPT_DIR}/${GLOBAL_FILE}")
    FILES+=( "${RELATIVE_PATH}" )
done

TEMP_DIR=$(mktemp -d /tmp/apia_test.XXXXXXXXXX)

if [[ -n "${DEBUG}" ]]; then
    echo "${TEMP_DIR}"
fi

if [[ "${DEBUG}" == 'trace' ]]; then
    clingo --opt-mode=optN --const test="${TEST_NUM}" --const max_timestep="${MAX_TIMESTEP}" --warn=no-atom-undefined "${FILES[@]}" --text 1 \
        | tee "${TEMP_DIR}/ground_program"
fi

clingo -t "$(nproc)" --opt-mode=optN --outf=3 --warn=no-atom-undefined \
    --const test="${TEST_NUM}" --const max_timestep="${MAX_TIMESTEP}" \
    "${FILES[@]}" 10 \
    > "${TEMP_DIR}/output"

awk -f "${SCRIPT_DIR}/display.awk" \
    -v temp_dir="${TEMP_DIR}" \
    "${TEMP_DIR}/output"

if [[ -n "${DEBUG}" ]]; then
    echo "Not deleting ${TEMP_DIR}. Remember to clean it up when finished debugging" >&2
else
    rm -rf "${TEMP_DIR}"
fi
