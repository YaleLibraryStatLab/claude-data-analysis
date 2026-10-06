# We Do code-reading and validation worksheet

Use the real salary data, your group's completed brief, and the saved R script.
The aim is to verify the handoff, not to diagnose a planted error.

## Stakeholder question and target

**Chosen stakeholder question:**

**Target quantity in one sentence:**

**Does rank belong inside the comparison? Why?**

## Your group's formulas

Primary formula:

Sensitivity formula (if any):

Uncertainty method, as stated in `report.md`:

Who chose it (group or Claude):

Can you explain what it does, and why it suits these data, without Claude?

If you have two formulas, explain in one sentence why they answer different
questions.

## Human inspection of `analysis.R`

Answer before asking the agent:

**Small syntax key:** In `factor(x, levels = c("Female", "Male"))`, the first
level is the reference. In `lm(y ~ x + z, data = d)`, the right side lists the
model terms. `nobs(fit)` reports how many rows entered the fitted model.

| Question | Evidence from the code |
|---|---|
| Which formula actually ran? | |
| What is the reference category for `sex`? | |
| What sign does the coefficient represent? | |
| How many rows entered the model? | |
| Which formula is primary and which is secondary? | |
| Which line computes the interval? Does it match `report.md`? | |
| Which substantive limit cannot be tested from the code? | |

## Independent check and its limit

Recompute the raw Male-minus-Female mean difference. Then complete:

> The raw check could reveal __________, but it cannot establish __________.

## Decision

Choose one for the computational handoff: **Approve / Revise / Stop / Escalate**

Give the reason and name any evidence or expertise still required.

## Comparison across groups

After the facilitator shows every group's results:

| Question | Your answer |
|---|---|
| Which group answered the same question as yours? Do the estimates agree? | |
| Where estimates differ, was the cause the target (formula) or the implementation (rows, reference level, interval)? | |
| Who chose each group's uncertainty method? Did groups that left it to Claude get the same method? | |
| Did another group's method change whether the difference looks clearly positive? | |
| Does each group's claim language match its formula? | |

## Calibrated handoff

> Among [population], the estimated [primary descriptive comparison] was
> [estimate], using [sample and formula]. The rank-adjusted comparison was
> [estimate] and answers [different target]. [Named limit] prevents [stronger
> claim].
