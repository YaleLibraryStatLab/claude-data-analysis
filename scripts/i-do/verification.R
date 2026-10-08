# Independent check of the primary headline quantity for the "I Do" case.
# Recomputes the adjusted difference and its HC2 standard error with explicit
# matrix algebra. Uses no lm(), no model.matrix(), no formula, no sandwich, and
# does not source or share code with analysis.R. The adjustment set is given
# here as an explicit include list (analysis.R uses an exclude list), so a
# mistake in either list shows up as a disagreement.
# Run from the project root:  Rscript --vanilla scripts/i-do/verification.R

raw <- read.csv("data/kam-palmer/political_socialisation_data.csv",
                colClasses = "character", na.strings = character(0))

youth <- c("PubAff", "Newspaper", "Radio", "Magazine", "FamTalk", "FrTalk", "AdultTalk",
           "PID", "GovtOpinion", "GovtCrook", "GovtWaste", "TrGovt", "GovtSmart", "Govt4All",
           "LifeWish", "GLuck", "FPlans", "WinArg", "StrOpinion", "MChange", "TrOthers",
           "OthHelp", "OthFair", "Senate", "Tito", "Court", "Govern", "CCamp", "FDR",
           "NextSch", "GPA", "SchOfficer", "SchPublish", "Hobby", "SchClub", "OccClub",
           "NeighClub", "RelClub", "YouthOrg", "MiscClub", "Phone", "Gen", "Race")
parent <- c("Newspaper", "Radio", "TV", "Magazine", "LifeWish", "GLuck", "FPlans", "WinArg",
            "StrOpinion", "MChange", "TrOthers", "OthHelp", "OthFair", "PID", "Vote",
            "Persuade", "Rally", "OthAct", "PolClub", "Button", "Money", "GovtOpinion",
            "GovtCrook", "GovtWaste", "TrGovt", "GovtSmart", "Govt4All", "Employ", "EducHH",
            "EducW", "FInc", "OwnHome", "ChurchOrg", "FratOrg", "ProOrg", "CivicOrg", "CLOrg",
            "NeighClub", "SportClub", "InfClub", "MiscClub", "Senate", "Tito", "Court",
            "Govern", "CCamp", "FDR", "Gen")
include <- c(paste0("y1965_", youth), paste0("p1965_", parent))
stopifnot(length(include) == 91, all(include %in% names(raw)))

# Indicator columns built by hand: one per observed value except the smallest.
cols <- list(intercept = rep(1, nrow(raw)), college = as.numeric(raw$college == "1"))
for (v in include) {
  vals <- sort(unique(as.numeric(raw[[v]])))
  for (k in vals[-1]) cols[[paste0(v, "_", k)]] <- as.numeric(as.numeric(raw[[v]]) == k)
}
X <- do.call(cbind, cols)
y <- as.numeric(raw$yppnscal)

XtX_inv <- solve(crossprod(X))
beta <- XtX_inv %*% crossprod(X, y)
e <- as.vector(y - X %*% beta)
h <- rowSums((X %*% XtX_inv) * X)
w <- ifelse(h > 1 - 1e-8, 0, e^2 / (1 - h))   # approved: leverage-1 row contributes 0
V <- XtX_inv %*% crossprod(X * w, X) %*% XtX_inv

est <- beta[2, 1]
se <- sqrt(V[2, 2])
df <- nrow(X) - ncol(X)
ci <- est + c(-1, 1) * qt(0.975, df) * se
cat(sprintf("verification: n = %d, columns = %d, residual df = %d\n", nrow(X), ncol(X), df))
cat(sprintf("verification: estimate = %.10f  HC2 se = %.10f  CI = [%.10f, %.10f]\n",
            est, se, ci[1], ci[2]))

# Second route for the point estimate only: partial out the covariates from
# both the outcome and the treatment, then take the ratio (Frisch-Waugh).
Z <- X[, -2]
P <- function(v) v - Z %*% solve(crossprod(Z), crossprod(Z, v))
ry <- P(y); rt <- P(X[, 2])
est_fwl <- sum(rt * ry) / sum(rt^2)
cat(sprintf("verification: partialling-out estimate = %.10f\n", est_fwl))

# Raw-column inspection behind the leverage-1 claim.
cat("\nraw y1965_FrTalk counts:\n"); print(table(raw$y1965_FrTalk))
i <- which(raw$y1965_FrTalk == "0")
cat("row with y1965_FrTalk == 0: interviewid", raw$interviewid[i], " leverage",
    format(h[i], digits = 12), " residual", format(e[i], digits = 3), "\n")
cat("largest leverage among other rows:", round(max(h[-i]), 4), "\n")

# Compare with the primary script's saved output.
res <- read.csv("scripts/i-do/results.csv")
p <- res[res$role == "primary", ]
diffs <- c(estimate = est - p$estimate, std_error = se - p$std_error,
           conf_low = ci[1] - p$conf_low, conf_high = ci[2] - p$conf_high,
           fwl_estimate = est_fwl - p$estimate)
cat("\ndifferences from results.csv (verification minus primary):\n")
print(signif(diffs, 3))
ok <- all(abs(diffs) < 1e-8)
cat("agreement within 1e-8:", ok, "\n")
if (!ok) quit(status = 1)
