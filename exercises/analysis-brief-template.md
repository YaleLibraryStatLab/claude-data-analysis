# Analysis brief

Use this template before asking a coding agent to analyze data. Replace every
bracketed instruction. If a section does not apply, say why.

## Goal

**Motivation:** [Why does this question matter?]

**Research question:** [State one answerable question.]

**Hypothesis:** [State a precommitted expectation, or state that there is none.]

**Target quantity:** [Define the population, comparison, outcome, and estimand.]

**Decision rule:** [What evidence would change the substantive conclusion?]

**Decision rights:** [List what the agent may execute, what it may only propose,
and what requires explicit human approval.]

**Delegation boundary:** [List consequential choices you can independently
evaluate. Name choices that require more learning or another expert.]

## Data

**Files:** [Give exact paths or filenames.]

**Provenance and access:** [Where did the data come from? Which files must remain
read-only? May the agent use external sources?]

**Structure:** [State the unit of observation, timing, repeated measures, groups,
weights, or dependence the analysis must respect.]

**Variable roles:** [Name the outcome, treatment or comparison, covariates, and
their coding.]

**Known uncertainties:** [List ambiguities, exclusions, missingness codes, or
documentation that may require confirmation.]

## Task

**Estimand:** [Restate the target quantity precisely.]

**Estimator:** [Specify the estimator, or ask the agent to compare defensible
options and wait for approval.]

**Specification:** [State adjustment logic, transformations, restrictions, and
variables that must not enter.]

**Uncertainty:** [Specify standard errors, confidence intervals, resampling, or
another uncertainty procedure.]

**Required checks:** [List data checks, diagnostics, falsification tests, and
sensitivity analyses.]

**Discriminating evidence:** [Name at least one result that could change your
judgment. Complete: "This check could reveal ___, but it cannot establish ___."]

## Output

- Write the complete analysis to `[analysis_filename]`.
- Write one machine-readable row to `[results_filename]` containing: [required
  fields, including estimand, estimator, sample size, estimate, and uncertainty].
- Write the rationale, assumptions, diagnostics, and limitations to
  `[report_filename]`.
- Write delegated choices, approvals, changes, and human interventions to
  `[decision_log_filename]`.
- Preserve the verbatim prompt and run log or transcript when available.

## Pause conditions

Stop after auditing the data and proposing an analysis plan. Do not fit a model
until the plan is approved.

Ask before any choice that changes the estimand, target population, adjustment
logic, inclusion criteria, or interpretation. Present the alternatives and the
consequences of each.

Do not choose a specification because it produces the expected direction or a
preferred significance result. If the data cannot answer the question, preserve
the work completed and explain why.

## Review before sending

- [ ] The target quantity has one clear meaning.
- [ ] The brief identifies every analytical choice delegated to the agent.
- [ ] A competent person can evaluate every consequential delegated choice.
- [ ] The requested files let another analyst reconstruct the run.
- [ ] The agent knows when to stop and request a decision.
