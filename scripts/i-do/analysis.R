# Checkpoint 3 analysis for the Kam-Palmer "I Do" case.
# Implements scripts/i-do/plan.md as approved on 2026-10-08. Descriptive
# target only: the adjusted difference in yppnscal (index points) between
# college attendees and non-attendees, averaged over the analysis sample.
# Run from the project root:  Rscript --vanilla scripts/i-do/analysis.R

library(sandwich)

in_path <- "data/kam-palmer/political_socialisation_data.csv"
out_dir <- "scripts/i-do"
cat("R:", R.version.string, "\n")
cat("sandwich:", as.character(packageVersion("sandwich")), "\n")
cat("input md5:", unname(tools::md5sum(in_path)), "\n\n")

d <- read.csv(in_path, na.strings = "NA")
stopifnot(nrow(d) == 1254, !anyDuplicated(d$interviewid))

# ---- Approved adjustment set -------------------------------------------------
# Audit section 8 exclusions, plus p1965_FarmGr (researcher: keep out).
# y1965_NextSch is included (researcher approval).
not_adjusters <- c(
  "interviewid", "college", "yppnscal",
  "y1965_Knowledge", "p1965_Knowledge", "y1965_SPID", "p1965_SPID",
  "y1965_ClubLev", "p1965_ClubLev", "p1965_HHInc", "p1965_Race",
  "p1965_WomenClub", "p1965_HHCollegePlacebo", "p1965_GPHighSchoolPlacebo",
  "p1965_FarmGr"
)
covs <- setdiff(names(d), not_adjusters)
stopifnot(length(covs) == 91, "y1965_NextSch" %in% covs,
          !anyNA(d[, c("college", "yppnscal", covs)]))

# Approved coding: three or more observed values -> unordered categories;
# two observed values -> 0/1 as stored. No level merged or recoded.
n_levels <- sapply(d[covs], function(x) length(unique(x)))
multi <- covs[n_levels > 2]
stopifnot(length(multi) == 62, all(n_levels >= 2))
a <- d[, c("interviewid", "college", "yppnscal", covs)]
for (v in multi) a[[v]] <- factor(a[[v]])
n <- nrow(a)
rhs <- paste(c("college", covs), collapse = " + ")

# HC2 weights with the approved handling of a leverage-1 row (plan section 6,
# option A): such a row has residual 0 and contributes 0.
hc2_omega <- function(residuals, diaghat, df) {
  ifelse(diaghat > 1 - 1e-8, 0, residuals^2 / (1 - diaghat))
}

# ---- Primary: additive OLS ---------------------------------------------------
fit <- lm(as.formula(paste("yppnscal ~", rhs)), data = a)
stopifnot(!anyNA(coef(fit)))
h <- hatvalues(fit)
V <- vcovHC(fit, omega = hc2_omega)

a1 <- transform(a, college = 1)
a0 <- transform(a, college = 0)
est <- mean(predict(fit, a1) - predict(fit, a0))
stopifnot(abs(est - coef(fit)[["college"]]) < 1e-10)
se <- sqrt(V["college", "college"])
df_res <- df.residual(fit)
ci <- est + c(-1, 1) * qt(0.975, df_res) * se

cat("== Primary: OLS, averaged predicted difference ==\n")
cat(sprintf("n = %d, coefficients = %d, residual df = %d\n", n, length(coef(fit)), df_res))
cat(sprintf("estimate = %.6f  HC2 se = %.6f  95%% CI = [%.6f, %.6f]\n", est, se, ci[1], ci[2]))

# ---- Diagnostics (plan section 8) --------------------------------------------
cat("\n== Diagnostics ==\n")
X <- model.matrix(fit)
cat("1. design columns:", ncol(X), " rank:", fit$rank, " aliased:", sum(is.na(coef(fit))), "\n")

lev1 <- a$interviewid[h > 0.99]
cat("2. leverage max:", round(max(h), 6), " n > 0.5:", sum(h > 0.5),
    " n > 0.99:", sum(h > 0.99), " ids > 0.99:", lev1, "\n")

cat("3. treatment counts within covariate levels with fewer than 10 rows:\n")
sparse <- do.call(rbind, lapply(multi, function(v) {
  t <- table(d[[v]], d$college)
  keep <- rowSums(t) < 10
  if (!any(keep)) return(NULL)
  data.frame(variable = v, level = rownames(t)[keep],
             college0 = t[keep, "0"], college1 = t[keep, "1"], row.names = NULL)
}))
print(sparse, row.names = FALSE)

f <- fitted(fit)
p1 <- predict(fit, a1); p0 <- predict(fit, a0)
out_range <- c(fitted = mean(f < 0 | f > 8), at_college1 = mean(p1 < 0 | p1 > 8),
               at_college0 = mean(p0 < 0 | p0 > 8))
cat("4. share outside [0, 8]:", paste(names(out_range), round(out_range, 4), collapse = "  "),
    "\n   fitted range:", round(range(f), 3), "\n")

cat("5. mean residual by decile of fitted value:\n")
dec <- cut(f, quantile(f, 0:10 / 10), include.lowest = TRUE, labels = 1:10)
binned <- data.frame(decile = 1:10, mean_fitted = round(tapply(f, dec, mean), 3),
                     mean_resid = round(tapply(resid(fit), dec, mean), 3),
                     sd_resid = round(tapply(resid(fit), dec, sd), 3))
print(binned, row.names = FALSE)
curv <- lm(resid(fit) ~ poly(f, 2))
cat("   quadratic-in-fitted term for residuals, t =",
    round(summary(curv)$coefficients[3, "t value"], 3), "\n")

# Leave-one-out change in the college coefficient (closed form). A leverage-1
# row has residual 0 and cannot move it.
XtXi <- chol2inv(qr.R(fit$qr))
cidx <- which(names(coef(fit)) == "college")
dfb <- ifelse(h > 1 - 1e-8, 0, as.vector(X %*% XtXi[, cidx]) * resid(fit) / (1 - h))
cat("6. largest leave-one-out change in college coefficient:", round(max(abs(dfb)), 5),
    "(id", a$interviewid[which.max(abs(dfb))], ") =", round(max(abs(dfb)) / se, 3), "HC2 se\n")

se_classical <- sqrt(vcov(fit)["college", "college"])
se_hc3 <- sqrt(vcovHC(fit, omega = function(residuals, diaghat, df)
  ifelse(diaghat > 1 - 1e-8, 0, residuals^2 / (1 - diaghat)^2))["college", "college"])
cat("7. se for information only: classical", round(se_classical, 6), " HC3", round(se_hc3, 6),
    " (reported HC2", round(se, 6), ")\n")

primary_status <- if (fit$rank == ncol(X) && identical(as.integer(lev1), 1668L)) {
  sprintf("no stop condition met; flagged: residual curvature against fitted values (quadratic t = %.1f) and %.1f%% of fitted values outside 0-8, so the linear form is imperfect; full rank; leverage 1 only for id 1668 (approved, zero HC2 contribution); max leave-one-out shift %.2f se",
          summary(curv)$coefficients[3, "t value"], 100 * out_range[["fitted"]], max(abs(dfb)) / se)
} else "STOP: plan failure condition met"

# ---- Alternative: fractional logit (plan section 7) --------------------------
cat("\n== Alternative: fractional logit, averaged predicted difference ==\n")
alt_warn <- character(0)
alt <- withCallingHandlers(
  glm(as.formula(paste("I(yppnscal / 8) ~", rhs)), data = a, family = quasibinomial("logit")),
  warning = function(w) { alt_warn <<- c(alt_warn, conditionMessage(w)); invokeRestart("muffleWarning") }
)
mu <- fitted(alt)
cat("8. converged:", alt$converged, " iterations:", alt$iter, " warnings:",
    if (length(alt_warn)) paste(alt_warn, collapse = " | ") else "none", "\n")
cat("   fitted proportion range:", format(range(mu), digits = 6),
    " n within 1e-6 of 0 or 1:", sum(mu < 1e-6 | mu > 1 - 1e-6), "\n")
cat("   outcome of the leverage-1 row (id 1668):", a$yppnscal[a$interviewid == 1668], "\n")

X1 <- model.matrix(delete.response(terms(alt)), a1)
X0 <- model.matrix(delete.response(terms(alt)), a0)
b <- coef(alt)
q1 <- plogis(as.vector(X1 %*% b)); q0 <- plogis(as.vector(X0 %*% b))
est_alt <- mean(8 * (q1 - q0))
grad <- 8 * colMeans(q1 * (1 - q1) * X1 - q0 * (1 - q0) * X0)
V_alt <- vcovHC(alt, omega = hc2_omega)
se_alt <- sqrt(as.numeric(t(grad) %*% V_alt %*% grad))
ci_alt <- est_alt + c(-1, 1) * qnorm(0.975) * se_alt
cat(sprintf("estimate = %.6f  delta-method HC2 se = %.6f  95%% CI = [%.6f, %.6f]\n",
            est_alt, se_alt, ci_alt[1], ci_alt[2]))
cat("   glm leverage max:", round(max(hatvalues(alt)), 6), " n > 0.99:", sum(hatvalues(alt) > 0.99), "\n")

alt_ok <- alt$converged && !length(alt_warn) && !any(mu < 1e-6 | mu > 1 - 1e-6)
alt_status <- if (alt_ok) {
  sprintf("no stop condition met; converged in %d iterations; no fitted proportion at 0 or 1", alt$iter)
} else "STOP: plan failure condition met (convergence or boundary fit)"

# ---- Outputs -----------------------------------------------------------------
estimand <- "Adjusted difference in yppnscal (index points), college 1 vs 0, averaged over the analysis sample; descriptive, not causal"
population <- "The 1,254 respondents in political_socialisation_data.csv (selection into file undocumented; unweighted)"
results <- data.frame(
  role = c("primary", "alternative"),
  estimand = estimand,
  target_population = population,
  estimator = c("Additive OLS outcome regression, 91 covariates (62 as unordered categories); HC2 se; t interval",
                "Fractional logit (quasi-binomial) outcome regression for yppnscal/8, same covariates; averaged predictions; delta-method HC2 se; normal interval"),
  n = n,
  estimate = c(est, est_alt),
  std_error = c(se, se_alt),
  conf_low = c(ci[1], ci_alt[1]),
  conf_high = c(ci[2], ci_alt[2]),
  diagnostic_status = c(primary_status, alt_status)
)
write.csv(results, file.path(out_dir, "results.csv"), row.names = FALSE)

diagnostics <- data.frame(
  quantity = c("design_columns", "rank", "residual_df", "max_leverage", "n_leverage_gt_0.5",
               "n_leverage_gt_0.99", "share_fitted_outside_0_8", "share_pred_college1_outside_0_8",
               "share_pred_college0_outside_0_8", "min_fitted", "max_fitted",
               "resid_quadratic_t", "max_abs_loo_shift", "max_abs_loo_shift_in_se",
               "se_classical", "se_hc2", "se_hc3", "alt_converged", "alt_iterations",
               "alt_min_fitted_prop", "alt_max_fitted_prop"),
  value = c(ncol(X), fit$rank, df_res, max(h), sum(h > 0.5), sum(h > 0.99), out_range[["fitted"]],
            out_range[["at_college1"]], out_range[["at_college0"]], min(f), max(f),
            summary(curv)$coefficients[3, "t value"], max(abs(dfb)), max(abs(dfb)) / se,
            se_classical, se, se_hc3, as.numeric(alt$converged), alt$iter, min(mu), max(mu))
)
write.csv(diagnostics, file.path(out_dir, "diagnostics.csv"), row.names = FALSE)

cat("\n== results.csv ==\n")
print(results[, c("role", "n", "estimate", "std_error", "conf_low", "conf_high")], row.names = FALSE)
cat(results$diagnostic_status, sep = "\n")
cat("\nwarnings():\n"); print(warnings())
cat("\nsessionInfo:\n"); print(sessionInfo())
