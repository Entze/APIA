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

GLOBAL_FILES=(
    aaa_axioms.lp
    aia_theory_of_intentions.lp
    aia_history_rules.lp
    aia_intended_action_rules.lp
    aopl_authorization_compliance.lp
    aopl_obligation_compliance.lp
    general_axioms.lp
    test.lp
)

for GLOBAL_FILE in "${GLOBAL_FILES[@]}"; do
    RELATIVE_PATH=$(realpath --relative-to . "${SCRIPT_DIR}/${GLOBAL_FILE}")
    FILES+=( "${RELATIVE_PATH}" )
done

TEMP_DIR=$(mktemp -d)
# echo "${TEMP_DIR}"

# clingo --opt-mode=optN --const test="${TEST_NUM}" --const max_timestep="${MAX_TIMESTEP}" --warn=no-atom-undefined "${FILES[@]}" --text 1 \
#     | tee "${TEMP_DIR}/ground_program"

clingo --opt-mode=optN --const test="${TEST_NUM}" --const max_timestep="${MAX_TIMESTEP}" --warn=no-atom-undefined "${FILES[@]}" 0 \
    > "${TEMP_DIR}/full_output"

clingo --opt-mode=optN --const test="${TEST_NUM}" --const max_timestep="${MAX_TIMESTEP}" --warn=no-atom-undefined "${FILES[@]}" 1 \
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
    | tr ' ' '\n' \
    | sort \
    > "${TEMP_DIR}/predicates"

cat "${TEMP_DIR}/subprograms" "${TEMP_DIR}/predicates"
rm -rf "${TEMP_DIR}"
