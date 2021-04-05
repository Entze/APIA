#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

MAX_TIMESTEP=7

cd "${SCRIPT_DIR}" || exit 2

FILES=(
    domain_encoding.lp
    instance.lp
    run_observations.lp
)

../../../Implementation/apia_control_loop.py --max-timestep "${MAX_TIMESTEP}" "${FILES[@]}" "$@"
