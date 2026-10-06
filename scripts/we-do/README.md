# We Do generated artifacts

Each group writes its brief, audit, plan, analysis, results, and run log under
`scripts/we-do/<group-name>/`. Every group's `results.csv` uses the shared columns
named in `exercises/we-do-salaries-analysis-brief.md`. Inputs under
`../../data/salaries/` remain read-only.

Each group picks a group name and uses it for its folder. Its `analysis.R` also
writes `submission.txt`, one `|`-separated line per model, which records the
uncertainty method used and whether the group or Claude chose it. On the class form the
group enters its name and pastes that file's contents. The facilitator downloads
the form responses as CSV and runs
`Rscript --vanilla scripts/we-do/compare-group-results.R path/to/responses.csv`.
The script groups matching specifications, keeps a group's latest resubmission,
flags rows whose sample size or interval cannot be compared, and writes
`group-comparison.csv` for the debrief. With no argument it reads
`form-responses.csv` in this folder if present, and otherwise the
`<group-name>/results.csv` folders.

`salaries-reference-analysis.R` is the facilitator-validated reference shown in
the deck. It fits the specifications groups can choose, reports conventional,
HC2, and HC3 intervals (groups may use other uncertainty methods), checks the raw Male-minus-Female contrast independently, and
writes `salaries-reference-results.csv`. It is a reference calculation, not a
simulated agent artifact.
