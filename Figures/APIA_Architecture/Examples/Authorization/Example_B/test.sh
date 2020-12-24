#!/usr/bin/env bash
clingo --opt-mode=optN --const max_timestep=4 --const test="$1" ../generic_encoding.lp ../../../AOPL_Util/authorization_compliance.lp ../../../aia_theory_of_intentions.lp ../../../aia_reasoning_tasks.lp domain_encoding.lp instance.lp ../sanity_checks.lp tests.lp 0 \
    | grep 'Answer:' -A1 | tail -n 2 | sed -n '2p' | tr ' ' '\n' | sort
