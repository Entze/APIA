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

DEBUG=

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

TEMP_DIR=$(mktemp -d)

if [[ -n "${DEBUG}" ]]; then
    echo "${TEMP_DIR}"
fi

if [[ "${DEBUG}" == 'trace' ]]; then
    clingo --opt-mode=optN --const test="${TEST_NUM}" --const max_timestep="${MAX_TIMESTEP}" --warn=no-atom-undefined "${FILES[@]}" --text 1 \
        | tee "${TEMP_DIR}/ground_program"
fi

clingo --opt-mode=optN --const test="${TEST_NUM}" --const max_timestep="${MAX_TIMESTEP}" --warn=no-atom-undefined "${FILES[@]}" 0 \
    > "${TEMP_DIR}/output"

grep 'Grounding:' "${TEMP_DIR}/output" \
    | sed -E 's/, (ASPSubprogramInstantiation)/,\n    \1/g' \
    | sed 's/,$//g' \
    | sed 's/)))$/))/g' \
    | sed 's/^Grounding: (/Grounding:\n    /g' \
    > "${TEMP_DIR}/subprograms"

grep 'Answer:' -A1 "${TEMP_DIR}/output" \
    | tail -n 2 \
    | sed -n '2p' \
    | sed -e 's/) /)\n/g' \
    | sort \
    > "${TEMP_DIR}/predicates"

if [[ "$(grep -c 'Answer: 1$' "${TEMP_DIR}/output")" -eq 1 ]]; then
    # Normal output
    NUM_MODELS=$(grep -c 'Answer:' "${TEMP_DIR}/output")
else
    # optN output (Ignore first 'Answer 1, 2, 3, ...' until Answer 1, 2, 3, ...)
    NUM_MODELS=$(grep 'Answer:' "${TEMP_DIR}/output" \
        | tail -n +2 \
        | sed -n '/Answer: 1$/,$p' \
        | wc -l )
fi

echo "Stable models: ${NUM_MODELS}"
cat "${TEMP_DIR}/subprograms" "${TEMP_DIR}/predicates"
if [[ -n "${DEBUG}" ]]; then
    echo "Not deleting ${TEMP_DIR}. Remember to clean it up when finished debugging" >&2
else
    rm -rf "${TEMP_DIR}"
fi
