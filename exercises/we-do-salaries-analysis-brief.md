# We Do group brief: faculty salaries

Each group starts from this brief. The sections marked **Given** are fixed for
every group so that results can be compared at the end. The sections marked
**Your group decides** are yours. First pick a short group name with no spaces
(for example `team-residual`); you will use it for your folder and on the class
form, so you can find your own result in the comparison. Copy this file to
`scripts/we-do/<group-name>/brief.md`, complete the decision sections, and only
then give it to Claude.

**Group name:** ______

Use the project root as the working directory. Treat `data/salaries/` as
read-only and write generated files only under `scripts/we-do/<group-name>/`.

## Goal

**Given — motivation:** The institution wants to describe salary differences
between women and men and understand how much those differences depend on the
comparison being made.

**Given — hypothesis:** Before viewing any estimate, we expect a positive
Male-minus-Female difference. This expectation must not guide model selection
or reporting.

**Given — claim boundary:** The result describes faculty at this college in
2008–09. It is descriptive. Do not use causal language about sex, and do not
generalize to faculty elsewhere.

**Your group decides — comparison.** Choose one and say why:

- [ ] the overall salary disparity between women and men;
- [ ] the difference among faculty with similar observed job context
  (discipline, experience);
- [ ] the difference among faculty of the same rank and similar job context.

**Your group decides — target quantity.** Write it in one sentence before
Claude fits anything:

> [The Male-minus-Female difference in expected nine-month salary among these
> 397 faculty, comparing people with the same ______.]

## Data

**Given — files:**

- `data/salaries/salaries.csv`
- `data/salaries/salaries_codebook.md`

**Given — structure:** One row represents one faculty member at one US
institution in the 2008–09 academic year. There are 397 rows, no missing
values, and no respondent identifier. Salary is a nine-month figure in dollars.

**Given — variables:** `salary` is the outcome and `sex` is the comparison of
interest. Candidate adjustment variables are `discipline`, `yrs.service`,
`yrs.since.phd`, and `rank`.

**Given — known limits:** The data contain 39 women and 358 men. The two
experience measures are strongly correlated (r ≈ 0.91). Rank may define a
within-rank comparison, or it may be part of the institutional disparity the
group wants to describe.

## Task

**Given — fixed for every group:**

- Female is the reference category; report Male minus Female.
- Use all 397 rows. Do not transform salary.
- Use a linear model with no interactions, so the `sexMale` coefficient is the
  adjusted difference.

**Your group decides — adjustment set for the primary model.**

| Variable | In the primary model? | Reason |
|---|---|---|
| `discipline` | yes / no | |
| `yrs.service` | yes / no | |
| `yrs.since.phd` | yes / no | |
| `rank` | yes / no | |

Primary formula: `salary ~ sex + ______`

**Your group decides — sensitivity model (optional, at most one).** Formula and
the different question it answers:

**Your group decides — uncertainty.** How should the uncertainty in this
difference be described? This is open. You may:

- choose a method yourselves and name it here;
- ask Claude to propose options at the plan checkpoint, then pick one; or
- write "Claude decides" and leave the choice to Claude.

Our choice: ______

If the group writes "Claude decides," the choice is explicitly delegated: Claude
chooses a method, names it in `plan.md` before fitting, and records that it made
the choice. Whoever chooses, `report.md` must state exactly what was done.

### Checkpoint 1: audit

Verify dimensions, missingness, factor levels, group sizes, salary support, and
the codebook claims. Do not estimate a salary difference. Write `audit.md` and
stop.

### Checkpoint 2: plan

After the group approves the audit, write `plan.md` restating the group's target,
primary formula, optional sensitivity formula, and uncertainty method, and say
who chose the uncertainty method. Stop for approval before fitting.

### Checkpoint 3: execute and verify

Implement only the approved formulas. Run the script with `Rscript --vanilla`,
recompute the raw Male-minus-Female mean difference directly, and confirm that
`results.csv` and `submission.txt` match the console output.

## Output

**Given — every group writes the same files under `scripts/we-do/<group-name>/`:**

- `brief.md` (this file, completed);
- `audit.md` and `plan.md`;
- `analysis.R`;
- `results.csv`: one row per model with exactly these columns:
  `group, role, target, formula, interval, chosen_by, n, estimate, conf_low, conf_high`
  - `group` is your group name;
  - `role` is `primary` or `sensitivity`;
  - `interval` is a short label, with no spaces, for the uncertainty method the
    code actually used, for example `conventional`, `HC3`, or
    `bootstrap-percentile-2000`; use `none` and `NA` bounds if no interval is
    reported;
  - `chosen_by` is `group` if the group named the method or picked it from
    Claude's options, and `claude` if the group left the choice to Claude;
- `report.md`: a short summary of what was done. It must state the target, the
  formula, the sample size, the estimate, the uncertainty method exactly as
  implemented (the function and its arguments), who chose that method and why,
  and one limit on what the result supports;
- `run-log.txt` from the clean-session run;
- `submission.txt`: written by `analysis.R` as its last step, directly from the
  rows of `results.csv` (do not type the numbers by hand). One line per model,
  fields separated by `|`, no header, numbers unrounded and without `$` or
  thousands separators, in exactly this order:

  `role|formula|interval|chosen_by|n|estimate|conf_low|conf_high|target`

  `analysis.R` must also print these lines to the console under the heading
  `SUBMISSION`.

**Given — submitting:** On the class form, enter your group name, then copy the
contents of `submission.txt` and paste them into the second field. That is the
only thing you send. The facilitator combines
every group's lines for the comparison.

## Decision rights and pause conditions

**Given:** Claude may audit, write R code for the approved formulas, run the
code, and draft files. It may not change the target, sample, adjustment set,
reference category, or claim language without proposing the change and stopping
for approval. Once `plan.md` is approved, it may not change the uncertainty
method either.

Pause if observed coding or missingness conflicts with this brief. Do not choose
a model because its estimate matches the hypothesis or another group's result.

## Before execution

Record in `brief.md`: the expected direction, one observable reason to distrust
the result, and one independent check. Each member must be able to explain the
primary formula without asking Claude. After the run, read the report's summary
of the uncertainty method and note whether you can explain it.
