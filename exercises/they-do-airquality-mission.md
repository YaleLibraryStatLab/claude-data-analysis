# They Do: direct a bounded ozone analysis

Work on your own from the workshop project root after the session. Treat
`data/airquality/` as read-only. Write only under `scripts/they-do/<your-id>/`.

This case has less scaffolding than the salary exercise. Use it to review the
workflow and to find which steps you can do confidently and which you cannot
yet evaluate. The objective is to direct, inspect, and bound an analysis with a
coding agent—not to maximize the number of models or files produced. The
suggested times below add up to about 30 minutes.

## Fixed scientific target

Estimate the adjusted difference in mean afternoon ozone concentration between
days at 85 degrees Fahrenheit and days at 75 degrees Fahrenheit. Standardize
over the observed distribution of wind, solar radiation, and month in the
approved analysis sample.

This is a descriptive adjusted association in the 1973 New York observations.
Do not describe it as a causal effect.

## Data

- `data/airquality/airquality.csv`
- `data/airquality/airquality_codebook.md`

One row is one calendar day. The file contains 153 consecutive days from May
through September 1973. Ozone is missing on 37 days, solar radiation on 7, and
nearby days may be statistically dependent.

## 1. Write the analysis brief before running code (about 8 minutes)

Create `scripts/they-do/<your-id>/brief.md` with six parts:

1. **Goal:** Restate the target contrast, motivation, and noncausal boundary.
2. **Data:** Record the unit, time order, input files, and read-only boundary.
3. **Task:** Specify the primary estimator and exact analysis sample, or ask the
   agent to propose options and stop for approval.
4. **Output:** Name the files and one independent check.
5. **Decision rights:** Name choices the agent may not change without approval.
6. **Stop conditions:** Name evidence or expertise limits that trigger revision,
   stopping, or escalation.

Name at least two decisions you retain.

## 2. Audit and approve a plan (about 10 minutes)

Ask the agent to audit the data and write `audit.md`, then stop. Review its
evidence about:

- month coding;
- complete-case sample and what population it represents;
- temperature support at 75 and 85 within months;
- plausible functional form for temperature;
- ordered daily observations and uncertainty;
- consistency between the codebook and the data.

Ask the agent for a plan only after reviewing the audit. Inspect the proposed R
formula and sample filter yourself. Record the plan and your approval,
revision, or escalation in `handoff.md`.

If a consequential statistical choice exceeds your expertise, do not
approve it merely because the agent recommends it. Narrow the task or record
the expertise needed.

## 3. Execute, check, and hand off (about 12 minutes)

If the plan is approved, ask the agent to write and run `analysis.R`. Require:

- `results.csv` with the 85-minus-75 estimate, interval, and sample size;
- a clean-session run log;
- one independent check chosen to expose a specific implementation error.

Complete `handoff.md` with the approved or rejected plan, check and its limit,
unresolved decisions, and one bounded claim or escalation.

Before finishing, check that you can explain each of the following without
asking the agent:

- the model formula;
- the analysis sample;
- the direction of the 85-minus-75 contrast;
- what the independent check can and cannot establish.

If execution is incomplete, preserve the partial work and write a clear stop or
escalation statement. That is a valid handoff.

## Review questions

1. What quantity and population does the result describe?
2. Which consequential choices were specified, and which did the agent supply?
3. Does the code implement the approved sample, estimator, contrast, and
   uncertainty procedure?
4. What evidence could expose an error, and what can it not establish?
5. Could you evaluate every choice you approved? Where you could not, what
   would you need to learn, or whom would you ask?
