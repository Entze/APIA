#!/usr/bin/env bash

print_usage() {
    echo "Usage: $0 [run|export]"
    exit 1
}

TIME_FORMAT=$'%U\t%S\t%e'

run_test() {
    # Machine info
    uname -s -r -m -o >&2
    lsb_release -a >&2
    grep 'model name' /proc/cpuinfo | uniq | head -n 1 >&2
    grep 'MemTotal' /proc/meminfo | uniq | head -n 1 >&2

    TRIALS=100

    # AIA
    echo $'User\tKernel\tTotal' > aia.tsv
    for TRIAL_NUM in $(seq 1 "${TRIALS}"); do
        echo "========== AIA: Trial ${TRIAL_NUM} of ${TRIALS} =========="
        env time -f "${TIME_FORMAT}" echo
    done > aia.txt 2>> aia.tsv

    # APIA (utilitarian, utilitarian)
    echo $'User\tKernel\tTotal' > apia_utilitarian_utilitarian.tsv
    for TRIAL_NUM in $(seq 1 "${TRIALS}"); do
        echo "========== APIA (utilitarian, utilitarian): Trial ${TRIAL_NUM} of ${TRIALS} =========="
        env time -f "${TIME_FORMAT}" ./run_utilitarian_utilitarian.sh
    done > apia_utilitarian_utilitarian.txt 2>> apia_utilitarian_utilitarian.tsv

    # APIA (best effort, best effort)
    echo $'User\tKernel\tTotal' > apia_best_effort_best_effort.tsv
    for TRIAL_NUM in $(seq 1 "${TRIALS}"); do
        echo "========== APIA (best effort, best effort): Trial ${TRIAL_NUM} of ${TRIALS} =========="
        env time -f "${TIME_FORMAT}" ./run_best_effort_best_effort.sh
    done > apia_best_effort_best_effort.txt 2>> apia_best_effort_best_effort.tsv

    # APIA (paranoid, subordinate)
    echo $'User\tKernel\tTotal' > apia_paranoid_subordinate.tsv
    for TRIAL_NUM in $(seq 1 "${TRIALS}"); do
        echo "========== APIA (paranoid, subordinate): Trial ${TRIAL_NUM} of ${TRIALS} =========="
        env time -f "${TIME_FORMAT}" ./run_paranoid_subordinate.sh
    done > apia_paranoid_subordinate.txt 2>> apia_paranoid_subordinate.tsv

    echo 'Test done' >&2
}

export_results() {
    echo 'Exporting results' >&2
    OUTPUT_FILES=(
        aia.tsv
        apia_utilitarian_utilitarian.tsv
        apia_best_effort_best_effort.tsv
        apia_paranoid_subordinate.tsv
    )
    paste "${OUTPUT_FILES[@]}" \
        | awk '{OFS="\t"; print $3, $6, $9, $12, $1 + $2, $4 + $5, $7 + $8, $10 + $11}' \
        | xclip -selection clipboard
}

if (( $# < 1 )); then
    print_usage
fi
MODE=$1

if [[ ${MODE} == 'run' ]]; then
    run_test
elif [[ ${MODE} == 'export' ]]; then
    export_results
else
    print_usage
fi
