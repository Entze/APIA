#!/usr/bin/env bash
clingo --const max_timestep=4 --const test=4 --warn=no-atom-undefined ../generic_encoding.lp ../../../authorization_compliance.lp domain_encoding.lp instance.lp ../sanity_checks.lp tests.lp 0 \
    | grep 'Answer:' -A1 | sed -n '2p' | tr ' ' '\n' | sort
