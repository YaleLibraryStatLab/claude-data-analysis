# I Do analysis brief: college attendance and political participation

Use this brief from the project root. Treat everything under `data/` as
read-only. Write all generated artifacts under `scripts/i-do/`.

## Goal

**Motivation:** College may build participatory skills and resources, but
pre-college family background, ability, and civic engagement also predict both
college attendance and later political participation.

**Starting research question:** Can these files support an estimate of the
average causal effect of attending college on later political participation
among respondents represented by this panel? If the required temporal ordering
cannot be established, stop and propose a descriptive adjusted association.

**Hypothesis:** Before seeing the result, we expect the effect to be positive.
This expectation must not guide estimator choice or specification search.

**Target quantity:** Begin with the full-sample average treatment effect (ATE)
as the requested scientific target. The audit must establish whether the
supplied documentation supports its temporal and consistency assumptions. If it
does not, the researcher may approve a different descriptive target: the
adjusted difference in the participation index between college attendees and
non-attendees, in index points. It is computed by predicting each respondent's
index with college set to 1 and to 0 and averaging the differences over the
analysis sample. It is not a difference in standard-deviation units. That
fallback must not be described as causal.

**Decision rule:** Treat failure of the causal timing requirement as a reason to
stop or reframe, not as a caveat added after estimation. For an approved
descriptive analysis, interpret magnitude together with its working-model
uncertainty, diagnostics, and planned alternative.

**Decision rights:** The agent may audit, propose options, write code, and run an
approved plan. The researcher retains the causal target, adjustment logic,
sample definition, uncertainty procedure, interpretation, and any reframe.

**Delegation boundary:** If the researcher cannot evaluate a consequential
estimator, uncertainty method, or identification claim, stop and seek expertise
or choose a narrower task that the researcher can evaluate. Do not treat the
agent's recommendation as approval.

## Data

**Files:**

- `data/kam-palmer/political_socialisation_data.csv`
- `data/kam-palmer/political_socialisation_codebook.md`

**Provenance and access:** The files are workshop copies of the 1965–1973
Political Socialization Panel Study materials used for the Kam and Palmer
example. Do not edit them. Do not use external data or search for the published
estimate until the workshop instructor authorizes comparison.

**Structure:** One row should represent one respondent. `interviewid` is the
putative unique identifier. Youth and parent covariates were recorded in 1965;
college attendance and the participation outcome were recorded at the 1973
follow-up.

**Variable roles:**

- Treatment: `college`, an indicator for having attended college by follow-up.
- Outcome: `yppnscal`, an additive index of eight political acts.
- Candidate pretreatment covariates require a substantively justified inventory
  and coding map supplied or approved by the researcher. A 1965 prefix alone
  does not justify adjustment.
- Variables with `Placebo` in their names are not automatically valid placebo
  outcomes; verify their provenance and empirical relationship to other fields.

**Known uncertainties:** Verify the row count, identifier uniqueness, treatment
and outcome support, missing-value coding, categorical-variable coding, and
temporal interpretation. Identify composites, deterministic transformations,
duplicate or near-duplicate variables, and discrepancies between labels and
data. State the limitation created by measuring college attendance and the
outcome in the same follow-up wave.

## Task

### Checkpoint 1: audit

Read the brief, dataset, and codebook. Do not fit an effect model. Write
`scripts/i-do/audit.md` covering:

- unit of observation, dimensions, identifier uniqueness, and duplicate rows;
- treatment and outcome coding, support, and missingness;
- missingness for candidate adjustment variables;
- inferred variable types and any disagreement with the documentation;
- composites, deterministic transforms, duplicate or near-duplicate columns;
- whether variables labeled as placebos are empirically distinct and have a
  defensible temporal interpretation;
- a proposed adjustment-variable inventory and variables to exclude; and
- unresolved conflicts that require a researcher decision.

End after writing the audit and wait for approval.

### Checkpoint 2: plan

After the audit is approved, state whether the requested causal target can be
identified from the supplied information. If temporal ordering is unresolved,
stop. Continue only after the researcher explicitly approves the descriptive
fallback target.

For that descriptive target, propose an outcome-regression analysis that
averages each respondent's predicted difference (college 1 versus 0) over the
analysis sample. No adjustment inventory or coding map is supplied in advance:
use the one the researcher approves from your audit proposal, and record it in
`scripts/i-do/decision-log.md`. Use HC2 heteroskedasticity-robust standard
errors for the primary estimate. State the analysis sample, functional-form
assumptions, required diagnostics, and failure conditions. Propose one alternative outcome
specification that preserves the same target and sample. Do not fit the model.
Write `scripts/i-do/plan.md`, record the proposed decisions in
`scripts/i-do/decision-log.md`, and wait for approval.

### Checkpoint 3: execute and verify

After the plan is approved:

- implement only the approved analysis;
- re-run it in a clean R session;
- recompute at least one key quantity by an independent route;
- inspect the raw columns behind at least one consequential data claim;
- run the approved alternative specification without changing the target or
  analysis sample; and
- stop and ask if a failure would require changing the target population,
  estimand, adjustment logic, or interpretation.

## Output

- `scripts/i-do/audit.md`: evidence-backed data audit.
- `scripts/i-do/plan.md`: approved analysis plan.
- `scripts/i-do/analysis.R`: complete analysis from read-only inputs to outputs.
- `scripts/i-do/verification.R`: separate implementation of one headline
  quantity that does not source or copy the primary script.
- `scripts/i-do/results.csv`: one row per approved estimator with estimand,
  target population, estimator, sample size, estimate, standard error,
  confidence limits, and diagnostic status.
- `scripts/i-do/report.md`: rationale, result, assumptions, diagnostics,
  sensitivity, and limitations.
- `scripts/i-do/decision-log.md`: prompts, approvals, revisions, commands,
  package versions, warnings, and human interventions.
- `scripts/i-do/run-manifest.csv`: every attempted, failed, superseded, and
  reported path with its disposition.

## Pause conditions

Ask before reframing the causal question, dropping observations, imputing
missing values, recoding an ambiguous field, changing the adjustment inventory,
or using a different model or uncertainty procedure. Never change the target or
population without explicit researcher approval. Do not choose a model because
its estimate matches the hypothesis or a published result.
