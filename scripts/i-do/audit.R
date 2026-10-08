# Checkpoint 1 data audit for the Kam-Palmer "I Do" case.
# Run from the project root:  Rscript --vanilla scripts/i-do/audit.R
# Reads data/ only. Fits no effect model and never tabulates the outcome
# against the treatment.

path <- "data/kam-palmer/political_socialisation_data.csv"
cat("R:", R.version.string, "\n")
cat("md5:", unname(tools::md5sum(path)), "\n\n")

# Read every field as text first so that no missing-value token is converted
# silently.
raw <- read.csv(path, colClasses = "character", na.strings = character(0))
cat("== 1. Dimensions and identifier ==\n")
cat("rows:", nrow(raw), " cols:", ncol(raw), "\n")
cat("duplicated interviewid:", sum(duplicated(raw$interviewid)), "\n")
cat("duplicated full rows:", sum(duplicated(raw)), "\n")
cat("duplicated rows ignoring interviewid:", sum(duplicated(raw[, -1])), "\n")
id <- as.integer(raw$interviewid)
cat("interviewid range:", range(id), " unused ids in range:",
    diff(range(id)) + 1 - length(id), "\n")
cat("rows sorted by id:", !is.unsorted(id), "\n")

cat("\n== 2. Non-numeric tokens and empty strings, by column ==\n")
tok <- lapply(raw, function(x) table(x[is.na(suppressWarnings(as.numeric(x)))]))
tok <- tok[lengths(tok) > 0]
for (v in names(tok)) {
  cat(v, ":", paste0("'", names(tok[[v]]), "'=", tok[[v]], collapse = " "), "\n")
}
cat("columns with no non-numeric token:", ncol(raw) - length(tok), "\n")

d <- as.data.frame(lapply(raw, function(x) suppressWarnings(as.numeric(x))))
miss <- colSums(is.na(d))
cat("\ncolumns with any missing after numeric conversion:\n")
print(miss[miss > 0])
cat("rows complete on all columns except the two Placebo columns:",
    sum(complete.cases(d[, !grepl("Placebo", names(d))])), "\n")

cat("\n== 3. Treatment and outcome (marginal only) ==\n")
print(table(college = d$college, useNA = "always"))
print(table(yppnscal = d$yppnscal, useNA = "always"))
cat("yppnscal mean/sd:", round(mean(d$yppnscal), 3), round(sd(d$yppnscal), 3), "\n")

cat("\n== 4. Observed values for every column ==\n")
for (v in names(d)[-1]) {
  t <- table(d[[v]], useNA = "ifany")
  cat(sprintf("%-26s %s\n", v,
              paste(round(as.numeric(names(t)), 4), t, sep = ":", collapse = "  ")))
}

cat("\n== 5. Codebook versus data column names ==\n")
cb <- readLines("data/kam-palmer/political_socialisation_codebook.md")
cbv <- sub("^\\| *([A-Za-z0-9_]+) *\\|.*$", "\\1", grep("^\\| *[a-z]", cb, value = TRUE))
cbv <- setdiff(cbv, "Variable")
cat("codebook variables:", length(cbv), "\n")
cat("in data not codebook:", setdiff(names(d), cbv), "\n")
cat("in codebook not data:", setdiff(cbv, names(d)), "\n")

cat("\n== 6. Documented composites ==\n")
kn <- c("Senate", "Tito", "Court", "Govern", "CCamp", "FDR")
for (p in c("y1965_", "p1965_")) {
  m <- rowMeans(d[, paste0(p, kn)])
  cat(p, "Knowledge == mean of six items (tol 1e-6):",
      sum(abs(m - d[[paste0(p, "Knowledge")]]) < 1e-6), "of", nrow(d), "\n")
}
yclub <- paste0("y1965_", c("SchOfficer", "SchPublish", "Hobby", "SchClub", "OccClub",
                            "NeighClub", "RelClub", "YouthOrg", "MiscClub"))
pclub <- paste0("p1965_", c("ChurchOrg", "FratOrg", "ProOrg", "CivicOrg", "CLOrg",
                            "NeighClub", "SportClub", "InfClub", "FarmGr", "WomenClub",
                            "MiscClub"))
try_composite <- function(target, items) {
  x <- d[, items]
  cand <- list(sum = rowSums(x), mean = rowMeans(x), max = do.call(pmax, x),
               min = do.call(pmin, x), n_gt1 = rowSums(x > 1),
               n_eq4 = rowSums(x == 4))
  for (n in names(cand)) {
    cat(sprintf("  %-14s vs %-6s exact match: %4d   cor: %6.3f\n", target, n,
                sum(cand[[n]] == d[[target]]), cor(cand[[n]], d[[target]])))
  }
  r <- sapply(items, function(i) cor(d[[i]], d[[target]]))
  eq <- sapply(items, function(i) sum(d[[i]] == d[[target]]))
  print(round(rbind(cor = r, n_equal = eq), 3))
}
try_composite("y1965_ClubLev", yclub)
try_composite("p1965_ClubLev", pclub)

cat("\n== 7. Duplicate and near-duplicate columns ==\n")
num <- d[, sapply(d, function(x) !anyNA(x))][, -1]
cm <- cor(num)
cm[lower.tri(cm, diag = TRUE)] <- NA
hi <- which(abs(cm) >= 0.6, arr.ind = TRUE)
out <- data.frame(a = rownames(cm)[hi[, 1]], b = colnames(cm)[hi[, 2]],
                  r = round(cm[hi], 3))
out$n_identical <- mapply(function(a, b) sum(num[[a]] == num[[b]]), out$a, out$b)
print(out[order(-abs(out$r)), ], row.names = FALSE)
cat("exactly identical column pairs:", sum(out$n_identical == nrow(num)), "\n")
cat("\nFInc x HHInc:\n")
print(table(FInc = d$p1965_FInc, HHInc = d$p1965_HHInc))
cat("EducHH x EducW:\n")
print(table(EducHH = d$p1965_EducHH, EducW = d$p1965_EducW))
cat("youth race x parent race:\n")
print(table(y = d$y1965_Race, p = d$p1965_Race))
cat("PID x SPID (youth), (parent):\n")
print(table(PID = d$y1965_PID, SPID = d$y1965_SPID))
print(table(PID = d$p1965_PID, SPID = d$p1965_SPID))

cat("\n== 8. Columns named Placebo ==\n")
gp <- raw$p1965_GPHighSchoolPlacebo
hc <- raw$p1965_HHCollegePlacebo
cat("HHCollegePlacebo x EducHH:\n"); print(table(hc, EducHH = d$p1965_EducHH))
cat("HHCollegePlacebo x EducW:\n"); print(table(hc, EducW = d$p1965_EducW))
cat("HHCollegePlacebo x max(EducHH, EducW):\n")
print(table(hc, maxEduc = pmax(d$p1965_EducHH, d$p1965_EducW)))
cat("GPHighSchoolPlacebo x EducHH:\n"); print(table(gp, EducHH = d$p1965_EducHH))
cat("GPHighSchoolPlacebo x EducW:\n"); print(table(gp, EducW = d$p1965_EducW))
cat("GPHighSchoolPlacebo x HHCollegePlacebo:\n"); print(table(gp, hc))
cat("GPHighSchoolPlacebo x parent gender:\n"); print(table(gp, p_gen = d$p1965_Gen))
cat("identical to college: HHCollege", sum(hc == raw$college),
    " GPHighSchool", sum(gp == raw$college), "of", nrow(raw), "\n")
cat("GP 'NA' by other fields (share missing):\n")
for (v in c("p1965_Gen", "p1965_Race", "p1965_Employ", "p1965_OwnHome")) {
  print(round(tapply(gp == "NA", d[[v]], mean), 3))
}

cat("\n== 9. Coding checks behind specific audit claims ==\n")
cat("WomenClub x parent gender:\n"); print(table(d$p1965_WomenClub, p_gen = d$p1965_Gen))
cat("FarmGr x parent gender:\n"); print(table(d$p1965_FarmGr, p_gen = d$p1965_Gen))
cat("EducW x parent gender:\n"); print(table(d$p1965_EducW, p_gen = d$p1965_Gen))
cat("Employ x parent gender:\n"); print(table(d$p1965_Employ, p_gen = d$p1965_Gen))
cat("youth Newspaper x Radio (code 5):\n"); print(table(d$y1965_Newspaper, d$y1965_Radio))
cat("parent Newspaper x Radio (code 0):\n"); print(table(d$p1965_Newspaper, d$p1965_Radio))
cat("youth SchOfficer x ClubLev:\n"); print(table(d$y1965_SchOfficer, d$y1965_ClubLev))
cat("y1965_FrTalk == 0 row id:", raw$interviewid[d$y1965_FrTalk == 0], "\n")
cat("y1965_GPA == 5 row ids:", raw$interviewid[d$y1965_GPA == 5], "\n")
cat("rare cells (n < 10) among integer-coded columns:\n")
for (v in names(num)) {
  t <- table(num[[v]])
  if (length(t) <= 10 && any(t < 10)) cat(" ", v, ":", paste(names(t)[t < 10], t[t < 10], sep = "=", collapse = " "), "\n")
}
cat("youth MiscClub x ClubLev:\n"); print(table(MiscClub = d$y1965_MiscClub, ClubLev = d$y1965_ClubLev))
cat("parent MiscClub x ClubLev:\n"); print(table(MiscClub = d$p1965_MiscClub, ClubLev = d$p1965_ClubLev))
cat("HHInc > FInc rows:", sum(d$p1965_HHInc > d$p1965_FInc), " of which HHInc == 7:",
    sum(d$p1965_HHInc > d$p1965_FInc & d$p1965_HHInc == 7), "\n")
cat("HHInc < FInc rows:", sum(d$p1965_HHInc < d$p1965_FInc), " equal:",
    sum(d$p1965_HHInc == d$p1965_FInc), "\n")
cat("EducW > EducHH rows:", sum(d$p1965_EducW > d$p1965_EducHH), "\n")
cat("SPID == abs(PID - 4): youth", sum(d$y1965_SPID == abs(d$y1965_PID - 4)),
    " parent", sum(d$p1965_SPID == abs(d$p1965_PID - 4)), "\n")
cat("HHCollegePlacebo == (EducHH >= 5) among non-missing:",
    sum(d$p1965_HHCollegePlacebo == (d$p1965_EducHH >= 5), na.rm = TRUE), "of",
    sum(!is.na(d$p1965_HHCollegePlacebo)), "\n")
cat("constant columns:", names(d)[sapply(d, function(x) length(unique(x)) == 1)], "\n")
cat("\nsessionInfo:\n"); print(sessionInfo())
