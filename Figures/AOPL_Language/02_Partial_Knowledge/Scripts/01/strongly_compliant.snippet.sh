#!/usr/bin/env bash
cd ../.. && clingo --quiet P.lp delta_V_lim.lp D.lp SL.lp Compliance_Checks/strongly_compliant.lp
