#!/usr/bin/env bash
GLOBAL_FILES=(  aaa_axioms.lp  aia_reasoning_tasks.lp  aia_theory_of_intentions.lp  aopl_authorization_compliance.lp  aopl_obligation_compliance.lp  misc_dynamic_domain.lp  )
clingo --opt-mode=optN --const max_timestep=4 --const test="$1" "${GLOBAL_FILES[@]}" domain_encoding.lp instance.lp ../sanity_checks.lp tests.lp 1 \
    | grep 'Answer:' -A1 | tail -n 2 | sed -n '2p' | tr ' ' '\n' | sort
