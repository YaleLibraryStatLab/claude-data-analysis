# Facilitator-validated reference analysis for the We Do section.
# Covers the specifications groups can choose in the We Do brief, with
# conventional, HC2, and HC3 intervals, so group results can be mapped onto it.
# Groups may use other uncertainty methods; a bootstrap interval will differ
# slightly from run to run and has no single reference value.
# Run from the workshop project root:
#   Rscript --vanilla scripts/we-do/salaries-reference-analysis.R
# Requires the sandwich package (see SETUP.md; install it before the workshop).

d <- read.csv("data/salaries/salaries.csv")

d$sex <- factor(d$sex, levels = c("Female", "Male"))
d$rank <- factor(d$rank, levels = c("AsstProf", "AssocProf", "Prof"))
d$discipline <- factor(d$discipline, levels = c("A", "B"))

stopifnot(
  nrow(d) == 397L,
  sum(is.na(d)) == 0L,
  identical(levels(d$sex), c("Female", "Male"))
)

# Labels are the full formulas so no row reads as cumulative when it is not.
specifications <- list(
  salary ~ sex,
  salary ~ sex + discipline,
  salary ~ sex + yrs.service,
  salary ~ sex + yrs.since.phd,
  salary ~ sex + discipline + yrs.service,
  salary ~ sex + discipline + yrs.since.phd,
  salary ~ sex + discipline + yrs.service + yrs.since.phd,
  salary ~ sex + rank,
  salary ~ sex + rank + discipline,
  salary ~ sex + rank + discipline + yrs.service,
  salary ~ sex + rank + discipline + yrs.service + yrs.since.phd
)

extract_sex_contrast <- function(formula) {
  fit <- lm(formula, data = d)
  estimate <- unname(coef(fit)["sexMale"])
  conventional <- confint(fit, parm = "sexMale", level = 0.95)
  hc2_se <- sqrt(sandwich::vcovHC(fit, type = "HC2")["sexMale", "sexMale"])
  hc3_se <- sqrt(sandwich::vcovHC(fit, type = "HC3")["sexMale", "sexMale"])
  t_crit <- qt(0.975, df = fit$df.residual)

  data.frame(
    formula = paste(deparse(formula), collapse = " "),
    includes_rank = "rank" %in% all.vars(formula),
    n = nobs(fit),
    estimate = estimate,
    conventional_low = conventional[1],
    conventional_high = conventional[2],
    hc2_low = estimate - t_crit * hc2_se,
    hc2_high = estimate + t_crit * hc2_se,
    hc3_low = estimate - t_crit * hc3_se,
    hc3_high = estimate + t_crit * hc3_se,
    row.names = NULL
  )
}

results <- do.call(rbind, lapply(specifications, extract_sex_contrast))

raw_difference <- with(
  d,
  mean(salary[sex == "Male"]) - mean(salary[sex == "Female"])
)

stopifnot(abs(raw_difference - results$estimate[1]) < 1e-8)

write.csv(
  results,
  "scripts/we-do/salaries-reference-results.csv",
  row.names = FALSE
)

print(results, digits = 6)
cat("\nIndependent raw Male - Female difference:", raw_difference, "\n")
