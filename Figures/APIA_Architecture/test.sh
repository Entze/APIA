#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if (( $# < 2 )); then
    echo "Usage: $0 FILE [...]" >&2
    exit 1
fi

TEST_NUM=$1
shift
FILES=( "$@" )

GLOBAL_FILES=(
    aaa_axioms.lp
    aia_reasoning_tasks.lp
    aia_theory_of_intentions.lp
    aia_axioms.lp
    aopl_authorization_compliance.lp
    aopl_obligation_compliance.lp
    general_axioms.lp
)

for GLOBAL_FILE in "${GLOBAL_FILES[@]}"; do
    RELATIVE_PATH=$(realpath --relative-to . "${SCRIPT_DIR}/${GLOBAL_FILE}")
    FILES+=( "${RELATIVE_PATH}" )
done

clingo --opt-mode=optN --const max_timestep=4 --const test="${TEST_NUM}" "${FILES[@]}" 1 \
    | grep 'Answer:' -A1 | tail -n 2 | sed -n '2p' | tr ' ' '\n' | sort
