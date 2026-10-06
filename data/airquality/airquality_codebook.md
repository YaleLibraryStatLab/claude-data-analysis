# Codebook: New York air quality, May to September 1973

The file contains 153 daily observations from New York between May and
September 1973. It is an exported copy of `datasets::airquality` from R.

## Variables

| Variable | Type | Description |
|---|---|---|
| `Ozone` | numeric | Mean ozone concentration in parts per billion from 1:00 to 3:00 p.m. at Roosevelt Island |
| `Solar.R` | numeric | Solar radiation in Langleys from 8:00 a.m. to noon at Central Park |
| `Wind` | numeric | Average wind speed in miles per hour at 7:00 and 10:00 a.m. at LaGuardia Airport |
| `Temp` | integer | Maximum daily temperature in degrees Fahrenheit at LaGuardia Airport |
| `Month` | integer | Month number, 5 through 9 |
| `Day` | integer | Day of the month |

## Structure and missingness

- `Ozone` is missing on 37 days.
- `Solar.R` is missing on 7 days.
- `Wind`, `Temp`, `Month`, and `Day` are complete.
- 111 rows are complete for `Ozone`, `Solar.R`, `Wind`, `Temp`, and `Month`.
- `Temp` ranges from 56 to 97 degrees Fahrenheit.
- Rows follow calendar order. Measurements close together in time may be
  statistically dependent.

## Provenance

The data come from the New York State Department of Conservation and the
National Weather Service. The R documentation cites Chambers et al. (1983),
*Graphical Methods for Data Analysis*.

These observational data support descriptive associations. They do not, by
themselves, identify a causal effect of temperature on ozone.
