#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

MAX_TIMESTEP=12

FILES=(
    "${SCRIPT_DIR}/../example_t.lp"

    "${SCRIPT_DIR}/../Departments/domain_encoding.lp"
    "${SCRIPT_DIR}/../Departments/example_s.lp"
    "${SCRIPT_DIR}/../Departments/instance.lp"

    "${SCRIPT_DIR}/../Meetings/domain_encoding.lp"
    "${SCRIPT_DIR}/../Meetings/example_s.lp"
    "${SCRIPT_DIR}/../Meetings/instance.lp"

    "${SCRIPT_DIR}/../Movement/domain_encoding.lp"
    "${SCRIPT_DIR}/../Movement/example_s.lp"
    "${SCRIPT_DIR}/../Movement/instance.lp"

    "${SCRIPT_DIR}/../Objects/domain_encoding.lp"
    "${SCRIPT_DIR}/../Objects/example_s.lp"
    "${SCRIPT_DIR}/../Objects/instance.lp"
)

"${SCRIPT_DIR}/../../../Implementation/apia_control_loop.py" --max-timestep "${MAX_TIMESTEP}" "${FILES[@]}" "$@"
