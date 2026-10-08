# Checkpoint 2 analysis plan: college attendance and political participation

Status: **approved by the researcher on 2026-10-08** with section 12 decisions: `p1965_FarmGr` out; leverage-1 row kept (option A); delta-method alternative accepted. Text below is as proposed. The design facts
quoted below (column counts, rank, leverage) depend only on the covariates and
were computed without the outcome.

## 1. Identification statement

The requested causal target, the full-sample average treatment effect of
attending college on later political participation, **cannot be identified
from the supplied information.** Attendance and the outcome were recorded in
the same 1973 wave, seven of the eight acts have no reference period, and the
timing and definition of attendance are undocumented (audit section 3).

The researcher approved the descriptive fallback on 2026-10-08. Everything
below concerns that fallback only.

## 2. Target

- **Quantity:** the adjusted difference in the participation index
  (`yppnscal`, 0 to 8) between college attendees and non-attendees, in index
  points. It is computed by predicting each respondent's index with `college`
  set to 1 and to 0, holding their covariates fixed, and averaging the
  differences over the analysis sample.
- **Not** a difference in standard-deviation units and **not** a causal
  effect.
- **Hypothesis on record:** positive. It plays no part in any choice below.

## 3. Analysis sample

All 1,254 rows of `data/kam-palmer/political_socialisation_data.csv`. No rows
dropped, no imputation. All approved covariates, the treatment, and the
outcome are complete. Results describe these 1,254 respondents; the file's
selection rule is undocumented and there are no weights, so no claim is made
about a wider population.

## 4. Adjustment set and coding (as approved 2026-10-08)

- **Inventory:** the 90 columns in audit section 8 plus `y1965_NextSch`,
  91 covariates in total. The 14 exclusions in audit section 8 stand.
- **Coding:** the 29 covariates with two observed values enter as 0/1
  indicators. The 62 covariates with three or more observed values enter as
  unordered categories (one indicator per level, lowest code as reference).
  No level is merged or recoded.
- **`p1965_FarmGr`: not yet decided.** The audit left it unassigned and the
  approval did not mention it. It is out of the model unless the researcher
  says to include it (as unordered categories, 3 more parameters).

## 5. Primary estimator

Ordinary least squares regression of `yppnscal` on `college` and the
adjustment set, additive, with no interactions:

`yppnscal ~ college + [29 indicators] + [62 unordered factors]`

- 207 coefficients including the intercept, full column rank, 1,047 residual
  degrees of freedom.
- Because the model is linear and additive in `college`, every respondent's
  predicted difference equals the `college` coefficient, so the average over
  the sample is that coefficient. The script will still compute the average
  by explicit prediction at `college` = 1 and 0 and confirm the two agree.
- **Uncertainty:** HC2 heteroskedasticity-robust standard error (as the brief
  requires), 95% confidence interval from the t distribution with the
  residual degrees of freedom. It is a working-model interval, conditional on
  this sample and this specification, not a design-based one.

**Functional-form assumptions.** The outcome's conditional mean is linear and
additive in the covariate indicators; the college difference is the same at
every covariate profile; a bounded 0 to 8 count is modeled on the identity
scale, so fitted values may fall outside 0 to 8. Unordered coding makes no
assumption about the order or spacing of category codes.

## 6. One issue that needs a decision before fitting

`y1965_FrTalk` has a single row with code 0 (id 1668). Under unordered coding
that row gets its own indicator, so its leverage is exactly 1, its residual is
exactly 0, and **the HC2 formula divides 0 by 0 for that row.** All other rows
have leverage below 0.5 (median 0.16, 99th percentile 0.32).

| Option | What changes | Consequence |
|---|---|---|
| A. Keep the row and coding; set that row's HC2 contribution to 0 | Nothing in the sample or coding | The row cannot inform the `college` coefficient. The estimate and SE equal those from the other 1,253 rows. Reported n = 1,254 with this stated. The alternative model in section 7 may fail to converge if that row's outcome is 0 or 8 |
| B. Merge code 0 into another `y1965_FrTalk` level | Recodes an ambiguous field | The row contributes; requires choosing a level with no documentation for what 0 means |
| C. Drop id 1668 | Analysis sample becomes 1,253 | Same primary estimate as A; cleaner for the alternative model |

My recommendation is A, because it needs neither a recode nor a dropped row
and its effect on the estimate is stated exactly. This is the researcher's
decision under the brief's pause conditions.

## 7. Planned alternative specification (same target, same sample)

A fractional logit outcome regression: quasi-binomial GLM with logit link for
`yppnscal / 8` on the same right-hand side. Predict each respondent's index
(8 × fitted proportion) at `college` = 1 and 0, and average the differences
over the same 1,254 rows.

- **Why this one:** it respects the 0 to 8 bounds and lets the college
  difference vary with covariates through the link, which is the main
  functional-form assumption of the primary model.
- **Uncertainty:** delta-method standard error for the averaged difference
  using the HC2 sandwich covariance of the GLM coefficients; normal-based 95%
  interval.
- **Role:** a sensitivity check on functional form. The primary estimate stays
  the reported headline whatever the alternative shows.
- **Evaluation boundary:** if the researcher is not in a position to evaluate
  a delta-method interval for a GLM, say so and I will stop for a narrower
  alternative or outside expertise instead of proceeding on my recommendation.

## 8. Diagnostics

Reported for the primary model, with status recorded in `results.csv`:

1. **Design:** column rank and any aliased coefficient.
2. **Leverage:** maximum and count above 0.5 and above 0.99.
3. **Treatment variation within sparse levels:** every covariate level with
   fewer than 10 rows (currently `y1965_Newspaper` 4, `y1965_FrTalk` 0,
   `y1965_LifeWish` 2, `y1965_GPA` 5, `y1965_Race` 3, `p1965_CLOrg` 3 and 4),
   tabulated by `college`.
4. **Fitted range:** share of fitted values and of predictions at
   `college` = 0 and 1 outside 0 to 8.
5. **Residuals:** residuals against fitted values, checked for curvature.
6. **Influence:** the largest single-row change in the `college` coefficient
   (dfbeta), compared with its standard error.
7. **Uncertainty sensitivity:** classical and HC3 standard errors beside HC2,
   for information only. HC2 remains the reported one.
8. **Alternative model:** convergence, and any fitted proportion at 0 or 1.

## 9. Verification

- `verification.R` recomputes the primary estimate and its HC2 standard error
  by a separate route (matrix algebra on a design matrix it builds itself, no
  `lm`, no `sandwich`, and no code shared with `analysis.R`). Agreement
  required to 1e-8.
- Raw-column inspection of one consequential data claim: the `y1965_FrTalk`
  = 0 row and its leverage.
- `analysis.R` is run with `Rscript --vanilla` from the project root.

## 10. Failure and stop conditions

Stop and ask, without changing anything, if:

- the design is rank deficient in a way that aliases `college`;
- any row other than id 1668 has leverage above 0.99;
- `verification.R` disagrees with `analysis.R` beyond tolerance;
- the alternative model fails to converge or produces fitted proportions at
  0 or 1;
- any fix would require changing the target, sample, adjustment set, coding,
  or uncertainty procedure.

A surprising sign or size of the estimate is not a failure condition and will
not trigger any respecification.

## 11. Software

R 4.6.1, base packages plus `sandwich` 3.1.2 (already installed) for the HC2
covariance in `analysis.R`. No package installation.

## 12. Approvals needed to proceed

1. The plan as a whole (estimator, sample of 1,254, diagnostics, stop
   conditions).
2. `p1965_FarmGr`: include as unordered categories, or leave out.
3. The leverage-1 row: option A, B, or C in section 6.
4. The alternative specification and its uncertainty method (section 7).
