# Checkpoint 1 audit: college attendance and political participation

- Brief: `exercises/i-do-kam-palmer-analysis-brief.md`
- Data: `data/kam-palmer/political_socialisation_data.csv`
  (md5 `475da6dc691bef5c8dd006372c89019e`), read-only
- Codebook: `data/kam-palmer/political_socialisation_codebook.md`
- Evidence: every number below is printed by `scripts/i-do/audit.R` into
  `scripts/i-do/audit-log.txt` (section numbers in brackets refer to that log).
- Scope kept: no effect model was fitted, the outcome was never tabulated
  against the treatment, and no external source was consulted. The correlation
  screen in [7] included `college` and `yppnscal` only to detect duplicated
  columns; no pair involving either reached the 0.6 reporting threshold, and
  no other treatment or outcome association was computed.

## Summary of what needs a decision

1. **The causal target is not supported by the supplied documentation.** The
   files do not establish that college attendance preceded the acts counted in
   the outcome (section 3). Under the brief's decision rule this is a reason to
   stop or reframe, and the reframe is the researcher's call.
2. **The codebook has no value labels.** Category meanings and directions are
   not documented for any variable. Several fields are demonstrably not
   ordinal scales (section 5). A coding map cannot be verified from these
   files; it has to be supplied or approved.
3. **Both "Placebo" columns fail as supplied.** One is a deterministic recode
   of a candidate adjustment variable; the other is 23.5% missing with
   undocumented provenance (section 7).
4. **Both "composite" club variables are not composites of the listed items**
   (section 6).
5. **The file is a pre-selected subset** with no documented selection rule and
   no weights (section 1).

## 1. Unit, dimensions, identifier [1, 5]

| Check | Result |
|---|---|
| Rows × columns | 1,254 × 106 |
| Codebook variables | 106; names match the data exactly |
| `interviewid` duplicates | 0 |
| Duplicate rows (with and without the id) | 0 and 0 |
| `interviewid` range | 1 to 1,669; 415 ids in that range are absent |

One row per respondent is consistent with the data. The id gaps mean the file
is a subset of a longer id sequence. Neither file says how rows were selected
(panel attrition, complete-case filtering, or something else). There is no
weight, stratum, or cluster variable. "Respondents represented by this panel"
therefore cannot be given a design-based meaning from these files; any
estimate describes these 1,254 rows.

## 2. Treatment and outcome [3]

| Variable | Observed values | Missing |
|---|---|---|
| `college` | 0: 451 (36.0%), 1: 803 (64.0%) | 0 |
| `yppnscal` | integers 0 to 8; counts 188, 338, 264, 180, 109, 64, 66, 31, 14; mean 2.30, SD 1.90 | 0 |

- Both arms are well populated and the outcome uses its full documented
  range. It is a right-skewed bounded count: 42% of rows are at 0 or 1, 1.1%
  at 8.
- The eight component acts are not in the file, so the index cannot be
  recomputed or checked against its description.
- `college` sits under "Identifiers" in the codebook with no measurement year
  and no definition of "attended" (any enrollment, a minimum duration,
  completion, type of institution).

## 3. Temporal interpretation

What the supplied documents say:

- Codebook header: "Outcome measured 1973; all covariates measured 1965."
- Brief: college attendance and the outcome were both recorded at the 1973
  follow-up.
- Outcome label: eight acts "reported in 1973". Only one act carries a date
  (voted in 1972). The other seven have no reference period.

What cannot be established from them:

- **Treatment before outcome.** Acts other than the 1972 vote may have
  occurred at any time between 1965 and 1973, including before or during
  college attendance. The date of first attendance is not recorded.
- **A single well-defined treatment.** "Attended college by follow-up" pools
  different durations, timings, and completion statuses, including possible
  current enrollment in 1973.
- **Covariates before treatment** holds by wave for the 1965 items, with one
  qualification: `y1965_NextSch` ("plans for school next year") is a stated
  intention about the treatment itself (section 8).

Assessment: the temporal-ordering and consistency assumptions needed for the
full-sample ATE are not supported by the supplied documentation. Measuring
treatment and outcome in the same wave means an adjusted difference could
reflect participation that preceded or coincided with attendance, or selection
into attendance, and the data cannot separate these.

## 4. Missingness [2]

- 104 of 106 columns have no missing value and no non-numeric token.
- `p1965_GPHighSchoolPlacebo`: literal string `NA` in 295 rows (23.5%).
- `p1965_HHCollegePlacebo`: literal string `NA` in 7 rows (0.6%).
- No blank cells and no sentinel codes such as 8, 9, 98, 99 appear.

Complete data on about 90 survey attitude items is unusual. Combined with the
id gaps, it suggests earlier complete-case selection, imputation, or folding
of "don't know" into a substantive code. Evidence consistent with the last: on
many three-point items the middle code is very rare (for example
`y1965_LifeWish` 1: 505, 2: 3, 3: 746; `y1965_GovtSmart` 1: 1,075, 2: 13,
3: 166), which fits codes 1 and 3 being the two answers and 2 being a residual
category. This is an inference, not a documented fact.

## 5. Variable types and disagreements with the documentation [4, 9]

Inferred storage: 102 integer columns, 2 fractional (`*_Knowledge`), 2 text
because of the `NA` strings. Full value counts are in log section [4].

| Finding | Evidence | Consequence |
|---|---|---|
| No value labels anywhere | Codebook gives descriptions only | Direction of every scale and binary (including `y1965_Gen`, `p1965_Gen`, race codes) is unknown |
| `y1965_PubAff` labeled "number of courses" | Values 0: 66, 1: 1,188 | It is a binary indicator |
| `p1965_Magazine` labeled "frequency" | Values 0: 513, 1: 741 | Binary, unlike the youth version (1 to 3) |
| Youth media items have an off-scale top code | `y1965_Newspaper` 5: 181 after 4: 7; `y1965_Radio` 5: 428 after 4: 17 | Code 5 is probably "does not follow"; not an ordered scale |
| Parent media items have an off-scale zero | `p1965_Newspaper` 0: 184 after 1: 13; `p1965_Radio` 0: 422; `p1965_TV` 0: 103 | Same issue, opposite end, so youth and parent versions are coded differently |
| `p1965_WomenClub` code 2 means "not applicable" at least in part | All 534 rows with `p1965_Gen` = 1 have code 2; codes 1, 3, 4 occur only when `p1965_Gen` = 0 | Not ordinal; partly a recode of parent gender |
| `p1965_FarmGr` has the same shape | 1: 580, 2: 639, 3: 18, 4: 17 | Code 2 is probably also a structural category |
| Other 1 to 4 organization items | Code 1 dominant, 2 to 4 sparse | Ordering of 2, 3, 4 undocumented |
| `y1965_FrTalk` out-of-range value | One 0 (id 1668) on a 1 to 4 item | Possible missing code or error |
| `y1965_GPA` | 1: 101, 2: 592, 3: 523, 4: 35, 5: 3 | Direction unknown; code 5 (ids 106, 371, 1613) may be a residual category |
| `y1965_SchOfficer` | 1: 391, 2: 335, 3: 528 | Three codes for a yes/no label |
| `p1965_EducHH` labeled "highest level of education in household" | `p1965_EducW` exceeds it in 356 rows | It is not a household maximum; more likely the head's education |
| `p1965_FInc` and `p1965_HHInc` | r = 0.88; equal in 824 rows; HHInc lower in 412; HHInc higher in 18, of which 17 have HHInc = 7 | Two versions of one construct; the pile-up at 7 looks like a filled-in value |
| `*_Knowledge` precision | Values such as 0.16666667163372 | Single-precision artifact from an earlier file conversion; harmless |
| `p1965_Gen` | Code 1: 96% employed; code 0: 45% employed | Suggests 1 = father, 0 = mother, but this is undocumented |

## 6. Composites, deterministic transforms, near-duplicates [6, 7, 9]

| Relationship | Evidence | Status |
|---|---|---|
| `y1965_Knowledge` = mean of its six items | 1,254 of 1,254 rows | Exact composite, as documented |
| `p1965_Knowledge` = mean of its six items | 1,254 of 1,254 rows | Exact composite, as documented |
| `y1965_SPID` = abs(`y1965_PID` − 4) | 1,254 of 1,254 rows | Deterministic fold, not documented |
| `p1965_SPID` = abs(`p1965_PID` − 4) | 1,254 of 1,254 rows | Deterministic fold, not documented |
| `p1965_HHCollegePlacebo` = (`p1965_EducHH` ≥ 5) | 1,247 of 1,247 non-missing rows | Deterministic recode, not documented |
| `y1965_ClubLev` vs `y1965_MiscClub` | r = 0.93; ClubLev > 1 in 332 of 349 rows with MiscClub = 1 and 5 of 905 with MiscClub = 0 | ClubLev is the activity level for the miscellaneous club, not a composite of the nine listed items (sum, mean, max, min, and counts all fail) |
| `p1965_ClubLev` vs `p1965_MiscClub` | r = 0.87; same pattern (170 of 183 vs 7 of 1,071) | Same conclusion |
| `y1965_Race` vs `p1965_Race` | Equal in 1,244 rows; 10 disagree | Near-duplicate |
| `p1965_FInc` vs `p1965_HHInc` | r = 0.88 | Near-duplicate (section 5) |

No two columns are exactly identical and no column is constant. No other pair
of columns correlates at 0.6 or above apart from each knowledge index with its
own items.

## 7. Variables named "Placebo" [8]

**`p1965_HHCollegePlacebo`**

- Equals 1 exactly when `p1965_EducHH` is 5 or 6, and 0 when it is 1 to 4. The
  7 `NA` rows all have `p1965_EducHH` = 2.
- It is therefore not empirically distinct from a candidate adjustment
  variable. Once `p1965_EducHH` is in the model, a "placebo" test on this
  column is uninformative by construction.
- Its temporal reading is defensible (parental education precedes the youth's
  college attendance), which makes it a pre-treatment characteristic, not an
  outcome that college could not affect for some other reason.

**`p1965_GPHighSchoolPlacebo`**

- 295 rows (23.5%) are `NA`. Missingness varies with `p1965_EducHH` (35% at
  level 1, 11% at level 6), so it is not ignorable on its face.
- It is not a recode of `p1965_EducHH`, `p1965_EducW`, or the other placebo
  column, so it carries distinct information.
- "GP" is not defined. If it means grandparent, the variable predates the
  treatment by a generation, which is a defensible placebo-outcome reading,
  but the codebook does not say so and its position under "Parent 1965"
  does not settle the measurement wave.

Neither column equals `college`. Assessment: neither is usable as a placebo
outcome on the strength of its name. Using `p1965_GPHighSchoolPlacebo` would
need documented provenance and a decision about 295 missing rows, which the
brief reserves to the researcher.

## 8. Proposed adjustment inventory (for researcher approval)

This is a proposal built from the codebook groupings and the checks above. A
1965 prefix was not treated as sufficient: each group is listed with the
reason it could plausibly precede and predict both attendance and
participation, matching the brief's motivation (family background, ability,
civic engagement). I cannot verify the substantive coding, so the inventory
is conditional on the coding decisions in section 9.

**Proposed to include (90 columns)**

| Group | Variables | Rationale |
|---|---|---|
| Youth ability and school | `y1965_GPA`, `y1965_PubAff`, six knowledge items | Pre-college ability and civic knowledge |
| Youth political engagement | `y1965_Newspaper`, `Radio`, `Magazine`, `FamTalk`, `FrTalk`, `AdultTalk` | Pre-college engagement |
| Youth partisanship and efficacy | `y1965_PID`, `GovtOpinion`, `GovtCrook`, `GovtWaste`, `TrGovt`, `GovtSmart`, `Govt4All` | Pre-college political orientation |
| Youth personality | `y1965_LifeWish`, `GLuck`, `FPlans`, `WinArg`, `StrOpinion`, `MChange`, `TrOthers`, `OthHelp`, `OthFair` | Personal efficacy and trust |
| Youth civic participation | `y1965_SchOfficer`, `SchPublish`, `Hobby`, `SchClub`, `OccClub`, `NeighClub`, `RelClub`, `YouthOrg`, `MiscClub` | Pre-college participation |
| Youth demographics | `y1965_Gen`, `y1965_Race`, `y1965_Phone` | Demographics and a resource proxy |
| Parent socioeconomic | `p1965_EducHH`, `p1965_EducW`, `p1965_FInc`, `p1965_Employ`, `p1965_OwnHome` | Family resources |
| Parent political participation | `p1965_PID`, `Vote`, `Persuade`, `Rally`, `OthAct`, `PolClub`, `Button`, `Money` | Political socialization at home |
| Parent media, efficacy, personality, knowledge | four media items, six efficacy items, nine personality items, six knowledge items | Home political environment |
| Parent civic participation | nine organization items (all except `p1965_WomenClub` and `p1965_FarmGr`), including `p1965_MiscClub` | Family civic engagement |
| Parent demographics | `p1965_Gen` | Which parent answered |

**Proposed to exclude from adjustment (14 columns, counting the identifier, treatment, and outcome)**

| Variable | Reason |
|---|---|
| `interviewid` | Identifier |
| `y1965_Knowledge`, `p1965_Knowledge` | Exact means of items already included; perfectly collinear with them |
| `y1965_SPID`, `p1965_SPID` | Exact functions of `PID`; redundant if `PID` enters as categories |
| `y1965_ClubLev`, `p1965_ClubLev` | Mislabeled; near-recodes of `MiscClub` |
| `p1965_HHInc` | Near-duplicate of `p1965_FInc` with a suspicious pile-up at 7 |
| `p1965_Race` | Near-duplicate of `y1965_Race` |
| `p1965_WomenClub` | Code 2 is structurally determined by `p1965_Gen` |
| `p1965_HHCollegePlacebo` | Exact recode of `p1965_EducHH`; 7 missing |
| `p1965_GPHighSchoolPlacebo` | 23.5% missing; provenance undocumented |
| `college`, `yppnscal` | Treatment and outcome |

That leaves `y1965_NextSch` and `p1965_FarmGr` unassigned (section 9, items 4
and 6).

Each exclusion of a redundant column has a mirror-image option (keep the
composite and drop the items; keep `SPID` and enter `PID` as a number; keep
`HHInc` instead of `FInc`). These are substantive choices, listed in
section 9.

## 9. Unresolved conflicts requiring a researcher decision

1. **Target.** The supplied documentation does not support the temporal
   ordering or consistency assumptions for the ATE. Options: (a) stop;
   (b) approve the brief's descriptive fallback (adjusted difference in index
   points over the analysis sample, not described as causal); (c) supply
   documentation of act reference periods and attendance timing that would
   reopen the causal target.
2. **Population.** 415 ids are absent and no selection rule or weight is
   documented. Confirm that the target population for any estimate is the
   1,254 rows in this file, described as such.
3. **Coding map.** No value labels exist. Options: (a) the researcher
   supplies value labels from the original study documentation; (b) treat
   every multi-category variable as unordered categories, which makes no
   ordering assumption but spends many parameters and leaves sparse cells
   (for example `y1965_LifeWish` code 2 has 3 rows); (c) approve specific
   ordinal or numeric treatments variable by variable. I cannot evaluate
   which codes are ordered from these files, and I will not recode
   `y1965_FrTalk` = 0, `y1965_GPA` = 5, or the media top and bottom codes
   without instruction.
4. **`y1965_NextSch`.** It is measured before treatment but is a stated plan
   about the treatment. Including it adjusts for pre-college intention;
   excluding it leaves that selection unadjusted. The two choices answer
   different descriptive questions.
5. **Redundant pairs.** Items versus `Knowledge` index; `PID` versus `SPID`;
   `FInc` versus `HHInc`; youth versus parent race; `MiscClub` versus
   `ClubLev`.
6. **`p1965_FarmGr` and `p1965_WomenClub`.** Include as unordered categories,
   or exclude, given that code 2 appears structural.
7. **Size of the inventory.** 90 columns with 451 rows in the smaller arm is
   a large model once categorical items are expanded. Whether to adjust for
   all of them or a narrower substantively chosen set is an adjustment-logic
   decision.
8. **Placebo columns.** Confirm that neither is used as a placebo outcome, or
   supply the provenance of `p1965_GPHighSchoolPlacebo` and a rule for its
   295 missing rows.
9. **Outcome scale.** The outcome is a bounded 0 to 8 count. The brief fixes
   outcome regression with HC2 standard errors; the functional form (linear
   versus a count or bounded-outcome model for the planned alternative) is
   left for the plan.

No fitting, recoding, row dropping, or imputation has been done. Work stops
here pending approval of this audit.
