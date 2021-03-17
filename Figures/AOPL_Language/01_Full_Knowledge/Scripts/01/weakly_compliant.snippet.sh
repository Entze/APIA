#!/usr/bin/env bash
cd ../.. && clingo --quiet P.lp s0.lp instantiate_variables.lp A.lp Compliance_Checks/weakly_compliant.lp
