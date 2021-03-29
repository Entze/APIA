#!/usr/bin/env bash
cd ../.. && clingo --quiet P.lp delta_V_lim.lp D.lp SL.lp Compliance_Checks/weakly_compliant.lp
