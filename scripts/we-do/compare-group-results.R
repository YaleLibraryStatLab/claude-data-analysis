# Collect every group's result for the We Do comparison.
# Run from the workshop project root after groups finish.
#
# From the class form (download the responses as CSV first):
#   Rscript --vanilla scripts/we-do/compare-group-results.R path/to/responses.csv
# With no argument, the script uses scripts/we-do/form-responses.csv if it
# exists, and otherwise reads scripts/we-do/<group-name>/results.csv folders.
#
# The form has two questions: the group's name, and a long-answer field where
# the group pastes the contents of its submission.txt. That file has one line
# per model, in the format named in exercises/we-do-salaries-analysis-brief.md:
#   role|formula|interval|chosen_by|n|estimate|conf_low|conf_high|target
# interval is a short label for the uncertainty method actually used (any
# method, or "none"); chosen_by is "group" or "claude".

required <- c(
  "group", "role", "formula", "interval", "chosen_by",
  "n", "estimate", "conf_low", "conf_high", "target"
)
line_fields <- setdiff(required, "group")
numeric_fields <- c("n", "estimate", "conf_low", "conf_high")

as_number <- function(x) suppressWarnings(as.numeric(gsub("[$, ]", "", x)))

read_form <- function(path) {
  responses <- read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
  # The group-name question is whichever column header mentions group or team.
  name_col <- grep("group|team", names(responses), ignore.case = TRUE)[1]
  if (is.na(name_col)) message("No group-name column found; rows are labeled by number.")

  parse_line <- function(line, group) {
    parts <- trimws(strsplit(line, "|", fixed = TRUE)[[1]])
    # Tolerate a line that still starts with a group field.
    if (!tolower(parts[1]) %in% c("primary", "sensitivity")) {
      if (!nzchar(group)) group <- parts[1]
      parts <- parts[-1]
    }
    # Tolerate a line with no chosen_by field: the fourth field is then n.
    if (length(parts) >= 4L && !is.na(as_number(parts[4]))) {
      parts <- append(parts, "unstated", after = 3L)
    }
    if (length(parts) < length(line_fields)) {
      message("Skipped (expected ", length(line_fields), " fields) from ", group, ": ", line)
      return(NULL)
    }
    # The target sentence is last so it may contain any character.
    head_fields <- parts[seq_len(length(line_fields) - 1L)]
    target <- paste(parts[length(line_fields):length(parts)], collapse = "|")
    as.data.frame(as.list(setNames(c(group, head_fields, target), required)),
                  stringsAsFactors = FALSE)
  }

  parse_row <- function(i) {
    group <- if (is.na(name_col)) "" else trimws(as.character(responses[i, name_col]))
    if (is.na(group)) group <- ""
    cells <- unlist(lapply(responses[i, , drop = FALSE], as.character), use.names = FALSE)
    if (!is.na(name_col)) cells <- cells[-name_col]
    lines <- trimws(unlist(strsplit(cells[!is.na(cells)], "\r?\n")))
    lines <- lines[grepl("|", lines, fixed = TRUE)]
    lines <- lines[!grepl("^(group|role)\\s*\\|", lines)]
    if (length(lines) == 0L) return(NULL)
    out <- do.call(rbind, lapply(lines, parse_line, group = group))
    if (!is.null(out)) out$group[!nzchar(out$group)] <- paste("row", i)
    out
  }

  out <- do.call(rbind, lapply(seq_len(nrow(responses)), parse_row))
  if (is.null(out)) stop("No submission lines found in ", path)
  out$source <- path
  out
}

read_folders <- function() {
  paths <- list.files(
    "scripts/we-do", pattern = "^results\\.csv$",
    recursive = TRUE, full.names = TRUE
  )
  if (length(paths) == 0L) {
    stop("No form responses file and no scripts/we-do/<group-name>/results.csv files found.")
  }
  read_group <- function(path) {
    x <- read.csv(path, stringsAsFactors = FALSE)
    missing <- setdiff(required, names(x))
    if (length(missing) > 0L) {
      message(path, " is missing: ", paste(missing, collapse = ", "), " (skipped)")
      return(NULL)
    }
    x$source <- path
    x[c(required, "source")]
  }
  out <- do.call(rbind, lapply(paths, read_group))
  if (is.null(out)) stop("No results file had the shared columns.")
  out
}

args <- commandArgs(trailingOnly = TRUE)
default_form <- "scripts/we-do/form-responses.csv"
groups <- if (length(args) >= 1L) {
  read_form(args[1])
} else if (file.exists(default_form)) {
  read_form(default_form)
} else {
  read_folders()
}

groups[numeric_fields] <- lapply(groups[numeric_fields], as_number)
groups$role <- tolower(groups$role)
groups$chosen_by <- tolower(trimws(groups$chosen_by))

# A group that submits twice keeps only its latest line for each model.
key <- paste(tolower(groups$group), groups$role, groups$formula)
resubmitted <- duplicated(key, fromLast = TRUE)
if (any(resubmitted)) {
  message("Kept the latest of repeated submissions from: ",
          paste(unique(groups$group[resubmitted]), collapse = ", "))
  groups <- groups[!resubmitted, ]
}

# Flag rows that cannot be compared on the shared target before discussing them.
groups$flag <- ""
groups$flag[is.na(groups$estimate) | is.na(groups$n)] <- "unreadable number"
groups$flag[!is.na(groups$n) & groups$n != 397] <- "n differs from 397"
outside <- !is.na(groups$estimate) & !is.na(groups$conf_low) & !is.na(groups$conf_high) &
  (groups$conf_low > groups$estimate | groups$conf_high < groups$estimate)
groups$flag[outside] <- "interval excludes estimate"

# Put the same specification next to each other regardless of term order.
# Matching specifications should match to the dollar, so any gap within a
# block is an implementation difference, not a target difference.
groups$spec <- vapply(groups$formula, function(f) {
  terms <- tryCatch(attr(terms(as.formula(f)), "term.labels"),
                    error = function(e) NA_character_)
  if (anyNA(terms)) return(paste("unparsed:", f))
  paste(sort(terms), collapse = " + ")
}, character(1), USE.NAMES = FALSE)

block_estimate <- ave(groups$estimate, groups$role, groups$spec,
                      FUN = function(x) median(x, na.rm = TRUE))
groups <- groups[order(groups$role, -block_estimate, groups$spec, groups$interval), ]
write.csv(groups, "scripts/we-do/group-comparison.csv", row.names = FALSE)

options(width = 200)
shown <- groups[c("group", "role", "spec", "interval", "chosen_by", "n",
                  "estimate", "conf_low", "conf_high", "flag")]
shown[c("estimate", "conf_low", "conf_high")] <-
  lapply(shown[c("estimate", "conf_low", "conf_high")], round)
print(shown, row.names = FALSE, right = FALSE)

# Who chose the uncertainty method, and what each chooser ended up with.
cat("\nUncertainty method by who chose it (primary models):\n")
primary <- groups[groups$role == "primary", ]
chooser <- as.data.frame(table(chosen_by = primary$chosen_by, interval = primary$interval),
                         responseName = "groups", stringsAsFactors = FALSE)
chooser <- chooser[chooser$groups > 0, ]
print(chooser[order(chooser$chosen_by, -chooser$groups), ], row.names = FALSE, right = FALSE)
