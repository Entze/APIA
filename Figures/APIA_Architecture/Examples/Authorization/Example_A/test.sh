#!/usr/bin/env bash
clingo --opt-mode=optN --const max_timestep=4 --const test="$1" ../../../misc_dynamic_domain.lp ../../../aopl_authorization_compliance.lp ../../../aia_theory_of_intentions.lp ../../../aia_reasoning_tasks.lp domain_encoding.lp instance.lp ../sanity_checks.lp tests.lp 1 \
    | grep 'Answer:' -A1 | tail -n 2 | sed -n '2p' | tr ' ' '\n' | sort
