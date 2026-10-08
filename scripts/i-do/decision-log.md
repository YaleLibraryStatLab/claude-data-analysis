# Decision log: I Do case (Kam-Palmer)

Entries are chronological. Researcher decisions are recorded verbatim when
given; nothing here counts as approval unless marked "Researcher approved".

## 2026-10-08: Checkpoint 1 (audit)

- **Prompt (researcher):** "Follow the brief in
  exercises/i-do-kam-palmer-analysis-brief.md"
- **Agent action:** Read the brief and codebook; wrote and ran
  `scripts/i-do/audit.R`; wrote `scripts/i-do/audit.md`.
- **Command:** `Rscript --vanilla scripts/i-do/audit.R > scripts/i-do/audit-log.txt 2>&1`
  (exit 0, no warnings in the log).
- **Environment:** R 4.6.1 (2026-06-24), macOS (Darwin 24.6.0); base packages
  only; no packages installed.
- **Data:** `data/kam-palmer/political_socialisation_data.csv`, md5
  `475da6dc691bef5c8dd006372c89019e`; not modified.
- **Not done:** no effect model, no outcome-by-treatment tabulation, no
  recoding, row dropping, or imputation, no external data or web search.
- **Revisions:** the audit script was run three times as checks were added
  (see `run-manifest.csv`); only the final log is kept.
- **Agent proposals awaiting decision (not approved):** adjustment inventory
  and exclusions in `audit.md` section 8; the nine open items in section 9.
- **Researcher decisions:** none yet.
- **Status:** stopped for audit approval.

## 2026-10-08: Audit approval and Checkpoint 2 (plan)

- **Prompt (researcher), verbatim:** "I approve the descriptive fallback.
  Treat every multi-category variable as unordered categories. Include the
  covariate. Approved inventory."
- **Researcher approved:**
  1. Target: the descriptive fallback (adjusted difference in index points,
     averaged over the analysis sample; not causal).
  2. Coding map: every multi-category variable enters as unordered
     categories.
  3. `y1965_NextSch`: included.
  4. Inventory: the 90 columns proposed in `audit.md` section 8, with the 14
     exclusions listed there.
- **Agent interpretation (flagged, not researcher wording):**
  - "the covariate" is read as `y1965_NextSch`, the one variable the audit
    summary posed as include-or-exclude.
  - "Approved inventory" is read as also settling the redundant pairs and the
    placebo columns as proposed (items, `PID`, `FInc`, youth race, `MiscClub`
    kept; composites, `SPID`, `HHInc`, parent race, `ClubLev`, both placebo
    columns out).
  - "Multi-category" is operationalized as three or more observed values
    (62 of the 91 covariates); the 29 two-valued covariates enter as 0/1.
- **Not covered by the approval, carried into the plan as open:**
  - `p1965_FarmGr` (unassigned in the audit).
  - Confirmation that the analysis sample is all 1,254 rows.
- **Agent action:** wrote `plan.md`. Ran one outcome-free design check
  (inline `Rscript --vanilla -e`, exit 0, no warnings): 207 design columns,
  full rank, 1,047 residual df without `p1965_FarmGr` (210 and 1,044 with
  it); leverage exactly 1 for id 1668 (`y1965_FrTalk` = 0), below 0.5 for
  all other rows; `sandwich` 3.1.2 is installed.
- **Proposed decisions awaiting approval (`plan.md` section 12):**
  1. Primary: additive OLS, HC2 standard error, t interval, n = 1,254.
  2. `p1965_FarmGr`: in or out.
  3. Leverage-1 row: option A (keep, zero HC2 contribution; agent
     recommendation), B (merge level), or C (drop row).
  4. Alternative: fractional logit with averaged predictions and
     delta-method HC2 interval.
- **Not done:** no model fitted; outcome not used.
- **Status:** stopped for plan approval.

## 2026-10-08: Plan approval and Checkpoint 3 (execute and verify)

- **Prompt (researcher), verbatim:** "Please keep leverage-1 row. Keep
  p1965_FarmGR out. Delta-method is fine. Plan approved."
- **Researcher approved:**
  1. The plan as a whole (additive OLS, HC2, n = 1,254, diagnostics, stop
     conditions).
  2. `p1965_FarmGr` excluded. Final adjustment set: 91 covariates.
  3. Leverage-1 row (id 1668) kept. Agent interpretation: this is option A
     of `plan.md` section 6, including setting that row's HC2 contribution
     to 0, since A was the only option that keeps the row unchanged.
  4. Alternative: fractional logit with delta-method HC2 interval.
- **Agent action:** wrote `analysis.R` and `verification.R`; updated the
  status line of `plan.md` (content otherwise unchanged); wrote `report.md`.
- **Commands (project root, clean sessions):**
  - `Rscript --vanilla scripts/i-do/analysis.R > scripts/i-do/analysis-log.txt 2>&1` (exit 0)
  - `Rscript --vanilla scripts/i-do/verification.R > scripts/i-do/verification-log.txt 2>&1` (exit 0)
- **Environment:** R 4.6.1; `sandwich` 3.1.2 (pre-installed); nothing
  installed. Input md5 unchanged after the runs.
- **Warnings:** none in either log.
- **Results:** primary 0.654 (HC2 se 0.133; 95% interval 0.392 to 0.916);
  alternative 0.692 (se 0.131; 0.435 to 0.948). Verification agrees with the
  primary to within 4e-14.
- **Revision after the first run:** the `diagnostic_status` text in
  `analysis.R` first read "pass" for the primary model. Because the
  residual-curvature diagnostic showed misfit (quadratic t = 5.7) and 1.8% of
  fitted values are below 0, the text was changed to "no stop condition met;
  flagged: ...". Only that string changed; the model, sample, and estimates
  are identical between runs E1 and E2.
- **Stop conditions:** none met. The curvature finding is not a listed stop
  condition; it is reported as a flag and is the issue the approved
  alternative addresses. No respecification was made.
- **Additions beyond the brief's output list:** `audit.R`, `audit-log.txt`,
  `analysis-log.txt`, `verification-log.txt`, `diagnostics.csv`.
- **Not done:** no unadjusted difference, no other adjustment set, no
  subgroup or interaction model, no placebo test, no comparison with the
  published estimate.
- **Human interventions to date:** three researcher messages (initial brief,
  audit approval, plan approval); no manual edits to agent outputs observed.
