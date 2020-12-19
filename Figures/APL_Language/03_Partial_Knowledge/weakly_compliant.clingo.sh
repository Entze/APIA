#!/usr/bin/env bash
echo ':- not -permitted(assume_command(c1, m1)).' | clingo Pm.lp delta_V_lim.lp D.lp SL.lp -
