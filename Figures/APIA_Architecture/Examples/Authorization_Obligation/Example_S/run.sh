#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

MAX_TIMESTEP=12

cd "${SCRIPT_DIR}" || exit 2

FILES=(
    ../example_s.lp

    ../Departments/domain_encoding.lp
    ../Departments/example_s.lp
    ../Departments/instance.lp

    ../Meetings/domain_encoding.lp
    ../Meetings/example_s.lp
    ../Meetings/instance.lp

    ../Movement/domain_encoding.lp
    ../Movement/example_s.lp
    ../Movement/instance.lp

    ../Objects/domain_encoding.lp
    ../Objects/example_s.lp
    ../Objects/instance.lp
)

../../../Implementation/apia_control_loop.py --max-timestep "${MAX_TIMESTEP}" "${FILES[@]}" "$@"
