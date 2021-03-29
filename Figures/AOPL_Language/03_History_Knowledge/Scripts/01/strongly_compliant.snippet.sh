#!/usr/bin/env bash
cd ../.. && clingo --quiet P.lp D0.lp Hn.lp A.lp Inertia_Axiom.lp Compliance_Checks/strongly_compliant.lp
