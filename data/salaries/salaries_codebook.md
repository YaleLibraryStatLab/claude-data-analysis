# Codebook: 2008–09 Faculty Salaries

397 observations, 6 variables, no missing values.

Nine-month academic salaries for faculty at a US college during the 2008–09
academic year. Collected as part of an ongoing effort to monitor salary
differences between male and female faculty members.

Source: `carData::Salaries` (Fox & Weisberg, *An R Companion to Applied
Regression*). Exported to `salaries.csv`.

---

## Variables

| Variable | Type | Description |
|----------|------|-------------|
| `rank` | factor | Academic rank: `AsstProf`, `AssocProf`, `Prof` |
| `discipline` | factor | Department type: `A` = theoretical, `B` = applied |
| `yrs.since.phd` | integer | Years since the PhD was awarded |
| `yrs.service` | integer | Years of service at this institution |
| `sex` | factor | `Female` or `Male` |
| `salary` | integer | Nine-month salary, US dollars |

## Distributions

| | |
|---|---|
| `salary` | range 57,800 – 231,545 |
| `rank` | AsstProf 67, AssocProf 64, Prof 266 |
| `discipline` | A 181, B 216 |
| `sex` | Female 39, Male 358 |

---

## Notes

- All salaries are nine-month figures and are not adjusted for inflation or
  cost of living.
- `yrs.since.phd` and `yrs.service` are distinct: a person may have earned a
  PhD elsewhere before joining this institution.
- The data are from a single institution in a single year. They describe that
  institution and are not a sample from any wider population.
