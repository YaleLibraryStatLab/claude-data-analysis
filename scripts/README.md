# Scripts

Output folders for the three cases. Keeping them separate means each case's
brief, decisions, code, and evidence stay distinguishable.

- `i-do/`: output target for the Kam--Palmer instructor demonstration.
- `we-do/`: one subfolder per group for the salary analysis, plus the reference
  analysis shown in the slides and the script that compares group results.
- `they-do/`: one subfolder per participant for the ozone analysis.

Run scripts from the project root so the relative paths resolve, for example:

```sh
Rscript --vanilla scripts/we-do/salaries-reference-analysis.R
```
