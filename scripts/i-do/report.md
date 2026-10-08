# College attendance and political participation: descriptive report

Case: Kam-Palmer "I Do" demonstration. Date: 2026-10-08.
Inputs: `data/kam-palmer/political_socialisation_data.csv` (md5
`475da6dc691bef5c8dd006372c89019e`) and its codebook, both unmodified.

## Result

Among the 1,254 respondents in the file, those who attended college scored
**0.65 index points higher** on the eight-act participation index than
non-attendees with the same recorded 1965 characteristics (HC2 standard
error 0.13; 95% working-model interval 0.39 to 0.92). The index runs from 0
to 8 and averages 2.30 in this sample, so the adjusted difference is about
two-thirds of one act.

**This is an adjusted association, not an effect of college.** It was
approved as a fallback because the causal question could not be answered from
these files.

| Specification | n | Estimate | Std. error | 95% interval |
|---|---|---|---|---|
| Primary: additive OLS, HC2 | 1,254 | 0.654 | 0.133 | 0.392 to 0.916 |
| Alternative: fractional logit, delta-method HC2 | 1,254 | 0.692 | 0.131 | 0.435 to 0.948 |

Machine-readable values are in `results.csv`; diagnostics are in
`diagnostics.csv` and `analysis-log.txt`.

## Rationale and why the target changed

The brief asked whether the files support the average causal effect of
attending college on later participation. They do not:

- attendance and the outcome were both recorded at the 1973 follow-up;
- seven of the eight acts have no reference period, so they may have happened
  before or during college;
- when attendance began, how long it lasted, and what counts as "attended"
  are undocumented.

Following the brief's decision rule, this was treated as a reason to reframe,
not a caveat. The researcher approved the descriptive target on 2026-10-08:
predict each respondent's index with `college` set to 1 and to 0 from an
outcome regression, and average the differences over the analysis sample.

The hypothesis recorded in advance was a positive difference. The estimate is
positive. The specification, sample, and alternative were fixed and approved
before any model was fitted, and no specification was changed after seeing
results.

## Method as approved

- **Sample:** all 1,254 rows; none dropped, nothing imputed.
- **Adjustment set:** 91 covariates measured in 1965 (youth ability,
  engagement, orientation, personality, civic participation, demographics,
  and stated plans for school next year; parent socioeconomic status,
  participation, media use, attitudes, knowledge, and organizations). The
  list and the 15 columns left out are in `audit.md` section 8 and
  `decision-log.md`.
- **Coding:** 62 covariates with three or more values entered as unordered
  categories; 29 two-valued covariates as 0/1. No level merged or recoded.
- **Primary estimator:** additive OLS (207 coefficients, 1,047 residual
  degrees of freedom); HC2 standard error; t interval.
- **Alternative:** fractional logit for the index divided by 8 on the same
  covariates and rows; averaged predicted differences; delta-method standard
  error from the HC2 covariance; normal interval.

## Assumptions behind the numbers

- The interval is a working-model interval. It treats these rows as the
  population of interest and the specification as given. It carries no
  sampling-design meaning: the file has no weights and its selection rule is
  undocumented.
- The primary model assumes the conditional mean is linear and additive in
  the covariate indicators and that the college difference is the same at
  every covariate profile.
- Unordered coding avoids assuming any order for undocumented category codes,
  at the cost of many parameters.

## Diagnostics

No stop condition in the plan was met. Two items are flagged.

| Check | Finding |
|---|---|
| Design | 207 columns, full rank, nothing aliased |
| Leverage | Exactly 1 for id 1668 (the only `y1965_FrTalk` = 0 row); next largest 0.48. As approved, that row contributes 0 to the HC2 variance; it cannot inform the college coefficient |
| Sparse levels | Seven covariate levels have fewer than 10 rows. One, `y1965_GPA` = 5, has no treatment variation (3 rows, all non-attendees) |
| **Fitted range (flag)** | 1.8% of fitted values fall outside 0 to 8 (range −1.18 to 6.40), all below 0 |
| **Residual shape (flag)** | Mean residuals are positive in the lowest and highest fitted deciles (+0.35 and +0.44) and negative between; a quadratic term in the fitted value has t = 5.7. Residual spread rises with the fitted value. The linear form does not fully describe a bounded count |
| Influence | Largest leave-one-out change in the estimate is 0.037 (0.28 standard errors) |
| Standard errors | Classical 0.136, HC2 0.133, HC3 0.146. HC2 is the reported one |
| Alternative model | Converged in 5 iterations, no warnings, fitted proportions between 0.015 and 0.825 |

## Sensitivity

The alternative addresses the flagged functional-form problem directly,
because it respects the 0 to 8 bounds. It gives 0.69 against the primary 0.65,
a gap of 0.04, well inside either interval. The curvature is real, but it does
not move the averaged difference materially. The primary estimate remains the
headline, as planned.

Not examined, because they were not in the approved plan: other adjustment
sets (including dropping `y1965_NextSch`), ordered codings, interactions
between college and covariates, and subgroup differences.

## Verification

- `verification.R` rebuilt the design matrix from an explicit include list
  and recomputed the estimate, HC2 standard error, and interval by matrix
  algebra, without `lm`, `sandwich`, or any code from `analysis.R`. All four
  agree with `results.csv` to within 4e-14. A partialling-out calculation
  gives the same estimate.
- The script computed the average of explicit predictions at college 1 and 0
  and confirmed it equals the regression coefficient.
- Raw-column inspection: `y1965_FrTalk` has counts 1, 358, 584, 79, 232 for
  codes 0 to 4; the single code-0 row is id 1668, with leverage 1 and
  residual 0.
- Both scripts ran in clean sessions (`Rscript --vanilla`), exit status 0, no
  warnings. The verification covers the primary estimate only; the
  alternative has no independent recomputation.

## Limitations

1. **Not causal.** Temporal order between attendance and the counted acts is
   not established, and attendance is an undefined mixture of timings and
   durations. The difference may reflect participation during or before
   college, or selection into college on things not recorded.
2. **Population.** 415 ids in the 1 to 1,669 range are absent with no
   documented reason, and there are no weights. The result describes these
   1,254 respondents only.
3. **Undocumented coding.** No value labels were supplied. Several items
   contain codes that are probably structural or residual categories.
   Unordered coding protects against wrong orderings but not against a
   category mixing unlike respondents.
4. **Completeness of the data.** No covariate has a missing value, which
   suggests earlier filtering, imputation, or recoding that these files do
   not describe.
5. **Adjustment on a stated intention.** `y1965_NextSch` is a 1965 plan about
   further schooling. Including it means the comparison is among respondents
   with the same stated plan, which is a narrower contrast than one without
   it.
6. **Model size.** 207 coefficients for 1,254 rows (451 non-attendees) is a
   heavily parameterized working model; average leverage is 0.17.
7. **Outcome.** The eight component acts are not in the file, so the index
   could not be checked, and the difference cannot be attributed to any
   particular act.
8. **Placebo columns.** Neither column named "Placebo" was used: one is an
   exact recode of `p1965_EducHH` and the other is 23.5% missing with
   undocumented provenance. No placebo test supports this result.
9. **No external comparison.** The published estimate was not consulted, as
   the brief requires until the instructor authorizes it.
