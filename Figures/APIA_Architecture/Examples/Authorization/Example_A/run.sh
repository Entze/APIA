#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

MAX_TIMESTEP=7

FILES=(
    "${SCRIPT_DIR}/domain_encoding.lp"
    "${SCRIPT_DIR}/instance.lp"
    "${SCRIPT_DIR}/run_observations.lp"
)

"${SCRIPT_DIR}/../../../Implementation/apia_control_loop.py" --max-timestep "${MAX_TIMESTEP}" "${FILES[@]}" "$@"
