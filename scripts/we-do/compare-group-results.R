# Collect every group's result for the We Do comparison.
# Run from the workshop project root after groups finish.
#
# Download the class form's responses and put the file (.csv or .zip) in
# instructor_files/responses/. Then run:
#   Rscript --vanilla scripts/we-do/compare-group-results.R
# The script reads the newest file in that folder. To read a specific file:
#   Rscript --vanilla scripts/we-do/compare-group-results.R path/to/responses.csv
# If the folder is empty, it reads scripts/we-do/<group-name>/results.csv folders.
#
# Output: a table in the console, instructor_files/we-do-comparison.html to
# show the room, and instructor_files/we-do-comparison.csv.
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

# Messages are printed and also repeated at the foot of the HTML page.
notes <- character(0)
note <- function(...) {
  text <- paste0(...)
  notes <<- c(notes, text)
  message(text)
}

out_dir <- "instructor_files"
responses_dir <- file.path(out_dir, "responses")

# The newest .csv or .zip the facilitator dropped in instructor_files/responses/.
newest_response <- function() {
  files <- list.files(responses_dir, pattern = "\\.(csv|zip)$",
                      full.names = TRUE, ignore.case = TRUE)
  if (length(files) == 0L) return(NA_character_)
  files[which.max(file.mtime(files))]
}

# Google Forms delivers the CSV inside a zip; read it without unpacking by hand.
as_csv_path <- function(path) {
  if (!grepl("\\.zip$", path, ignore.case = TRUE)) return(path)
  inside <- unzip(path, list = TRUE)$Name
  inside <- inside[grepl("\\.csv$", inside, ignore.case = TRUE)]
  if (length(inside) == 0L) stop("No CSV inside ", path)
  unzip(path, files = inside[1], exdir = tempdir(), overwrite = TRUE)
  file.path(tempdir(), inside[1])
}

read_form <- function(path) {
  responses <- read.csv(as_csv_path(path), stringsAsFactors = FALSE, check.names = FALSE)
  # The group-name question is whichever column header mentions group or team.
  name_col <- grep("group|team", names(responses), ignore.case = TRUE)[1]
  if (is.na(name_col)) note("No group-name column found; rows are labeled by number.")

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
      note("Skipped (expected ", length(line_fields), " fields) from ", group, ": ", line)
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
    stop("No file in ", responses_dir, " and no scripts/we-do/<group-name>/results.csv files found.")
  }
  read_group <- function(path) {
    x <- read.csv(path, stringsAsFactors = FALSE)
    missing <- setdiff(required, names(x))
    if (length(missing) > 0L) {
      note(path, " is missing: ", paste(missing, collapse = ", "), " (skipped)")
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
input <- if (length(args) >= 1L) args[1] else newest_response()
groups <- if (is.na(input)) read_folders() else read_form(input)
message("Read: ", if (is.na(input)) "scripts/we-do/<group-name>/results.csv folders" else input)

groups[numeric_fields] <- lapply(groups[numeric_fields], as_number)
groups$role <- tolower(groups$role)
groups$chosen_by <- tolower(trimws(groups$chosen_by))

# A group that submits twice keeps only its latest line for each model.
key <- paste(tolower(groups$group), groups$role, groups$formula)
resubmitted <- duplicated(key, fromLast = TRUE)
if (any(resubmitted)) {
  note("Kept the latest of repeated submissions from: ",
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
dir.create(out_dir, showWarnings = FALSE)
write.csv(groups, file.path(out_dir, "we-do-comparison.csv"), row.names = FALSE)

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

# ---- HTML table to show the room -------------------------------------------
# Built here, from the same rows as the CSV, so no number is retyped.

esc <- function(x) {
  x <- gsub("&", "&amp;", as.character(x), fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  gsub("\"", "&quot;", x, fixed = TRUE)
}
dollars <- function(x) {
  ifelse(is.na(x), "",
         paste0(ifelse(x < 0, "&minus;", ""), "$",
                formatC(abs(round(x)), big.mark = ",", format = "d")))
}
adjusted_for <- function(spec) {
  if (startsWith(spec, "unparsed:")) return(spec)
  terms <- setdiff(strsplit(spec, " + ", fixed = TRUE)[[1]], "sex")
  if (length(terms) == 0L) "nothing (raw difference)" else paste(terms, collapse = " + ")
}

# One shared dollar scale for every interval strip, always including zero.
scale_values <- c(0, groups$estimate, groups$conf_low, groups$conf_high)
scale_min <- min(scale_values, na.rm = TRUE)
scale_max <- max(scale_values, na.rm = TRUE)
pad <- 0.04 * (scale_max - scale_min)
scale_min <- scale_min - pad
scale_max <- scale_max + pad
strip_w <- 300
x_at <- function(v) round(10 + (v - scale_min) / (scale_max - scale_min) * (strip_w - 20), 1)

strip <- function(est, low, high, label) {
  if (is.na(est)) return("")
  range_line <- if (is.na(low) || is.na(high)) "" else sprintf(
    '<line class="range" x1="%s" x2="%s" y1="14" y2="14"/>', x_at(low), x_at(high))
  sprintf(paste0(
    '<svg class="strip" viewBox="0 0 %d 28" width="%d" height="28" role="img" aria-label="%s">',
    '<title>%s</title><line class="zero" x1="%s" x2="%s" y1="2" y2="26"/>%s',
    '<circle class="dot" cx="%s" cy="14" r="5"/></svg>'),
    strip_w, strip_w, label, label, x_at(0), x_at(0), range_line, x_at(est))
}
axis_header <- sprintf(paste0(
  '<svg class="strip" viewBox="0 0 %d 22" width="%d" height="22" aria-hidden="true">',
  '<text class="tick" x="%s" y="16" text-anchor="middle">$0</text>',
  '<text class="tick" x="%s" y="16" text-anchor="end">%s</text></svg>'),
  strip_w, strip_w, x_at(0), strip_w - 2, gsub("&minus;", "-", dollars(scale_max - pad)))

row_html <- function(r) {
  interval_text <- if (is.na(r$conf_low) || is.na(r$conf_high)) {
    '<span class="muted">none reported</span>'
  } else paste(dollars(r$conf_low), "to", dollars(r$conf_high))
  label <- esc(paste0(r$group, ": ", gsub("&minus;", "-", dollars(r$estimate)),
                      if (is.na(r$conf_low)) "" else paste0(
                        " (", gsub("&minus;", "-", dollars(r$conf_low)), " to ",
                        gsub("&minus;", "-", dollars(r$conf_high)), ")")))
  flag <- if (nzchar(r$flag)) sprintf('<div class="flag">&#9888; %s</div>', esc(r$flag)) else ""
  sprintf(paste0(
    '<tr><td><div class="group">%s</div><div class="target">%s</div>%s</td>',
    '<td>%s</td><td><span class="who who-%s">%s</span></td><td class="num">%s</td>',
    '<td class="num est">%s</td><td class="num">%s</td><td>%s</td></tr>'),
    esc(r$group), esc(r$target), flag, esc(r$interval),
    if (r$chosen_by %in% c("group", "claude")) r$chosen_by else "other", esc(r$chosen_by),
    ifelse(is.na(r$n), "", r$n), dollars(r$estimate), interval_text,
    strip(r$estimate, r$conf_low, r$conf_high, label))
}

section_html <- function(role, title) {
  rows <- groups[groups$role == role, ]
  if (nrow(rows) == 0L) return("")
  body <- character(0)
  for (spec in unique(rows$spec)) {
    block <- rows[rows$spec == spec, ]
    body <- c(body, sprintf(
      '<tr class="block"><th colspan="7">Adjusted for: %s <span class="count">%d %s</span></th></tr>',
      esc(adjusted_for(spec)), nrow(block), if (nrow(block) == 1L) "group" else "groups"))
    body <- c(body, vapply(seq_len(nrow(block)), function(i) row_html(block[i, ]), character(1)))
  }
  paste0('<h2>', title, '</h2><div class="scroll"><table><thead><tr>',
         '<th>Group and target</th><th>Uncertainty method</th><th>Chosen by</th>',
         '<th class="num">n</th><th class="num">Estimate</th><th class="num">Interval</th>',
         '<th>', axis_header, '</th></tr></thead><tbody>',
         paste(body, collapse = "\n"), '</tbody></table></div>')
}

chooser_html <- paste0(
  '<h2>Uncertainty method by who chose it <span class="count">primary models</span></h2>',
  '<table class="small"><thead><tr><th>Chosen by</th><th>Method</th><th class="num">Groups</th></tr></thead><tbody>',
  paste(sprintf('<tr><td><span class="who who-%s">%s</span></td><td>%s</td><td class="num">%d</td></tr>',
                ifelse(chooser$chosen_by %in% c("group", "claude"), chooser$chosen_by, "other"),
                esc(chooser$chosen_by), esc(chooser$interval), chooser$groups)[
                  order(chooser$chosen_by, -chooser$groups)], collapse = "\n"),
  '</tbody></table>')

notes_html <- if (length(notes) == 0L) "" else paste0(
  '<h2>Notes from reading the responses</h2><ul class="notes">',
  paste(sprintf("<li>%s</li>", esc(notes)), collapse = "\n"), "</ul>")

page <- paste0('<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>We Do comparison</title>
<style>
:root { --surface:#fcfcfb; --raised:#f1f0ec; --ink:#0b0b0b; --ink2:#52514e; --muted:#898781;
        --rule:#dddcd6; --mark:#2a78d6; --critical:#d03b3b; }
@media (prefers-color-scheme: dark) {
  :root { --surface:#1a1a19; --raised:#262625; --ink:#ffffff; --ink2:#c3c2b7; --muted:#898781;
          --rule:#3a3a38; --mark:#5b9be6; --critical:#e06a6a; } }
body { background:var(--surface); color:var(--ink); margin:0; padding:24px 16px 48px;
       font:18px/1.4 system-ui, -apple-system, "Segoe UI", sans-serif; }
main { max-width:1280px; margin:0 auto; }
h1 { font-size:1.6rem; margin:0 0 4px; }
h2 { font-size:1.15rem; margin:32px 0 8px; }
p.sub { color:var(--ink2); margin:0; }
.scroll { overflow-x:auto; }
table { border-collapse:collapse; width:100%; }
table.small { width:auto; min-width:420px; }
th, td { text-align:left; padding:8px 12px; border-bottom:1px solid var(--rule); vertical-align:middle; }
thead th { font-size:.85rem; color:var(--ink2); font-weight:600; border-bottom:2px solid var(--rule); }
tr.block th { background:var(--raised); font-weight:600; border-bottom:none; }
.count { color:var(--ink2); font-weight:400; font-size:.85rem; margin-left:8px; }
.num { text-align:right; font-variant-numeric:tabular-nums; white-space:nowrap; }
.est { font-weight:700; }
.group { font-weight:600; }
.target { color:var(--ink2); font-size:.8rem; max-width:34ch; }
.muted { color:var(--muted); }
.who { display:inline-block; padding:1px 10px; border-radius:999px; border:1.5px solid var(--ink2); font-size:.85rem; }
.who-claude { border-style:dashed; }
.who-other { border-color:var(--muted); color:var(--ink2); }
.flag { color:var(--critical); font-size:.85rem; font-weight:600; margin-top:2px; }
.strip { display:block; }
.strip .zero { stroke:var(--muted); stroke-width:1; stroke-dasharray:3 3; }
.strip .range { stroke:var(--mark); stroke-width:2; stroke-linecap:round; }
.strip .dot { fill:var(--mark); stroke:var(--surface); stroke-width:2; }
.strip .tick { fill:var(--ink2); font-size:12px; }
ul.notes { color:var(--ink2); font-size:.9rem; padding-left:20px; }
</style></head><body><main>
<h1>We Do: Male minus Female salary difference, by group</h1>
<p class="sub">', length(unique(tolower(groups$group))), ' groups, ', nrow(groups),
  ' models. Groups with the same adjustment set are listed together; the estimate should match within a block. Dashed line marks $0.</p>',
  section_html("primary", "Primary models"),
  section_html("sensitivity", "Sensitivity models"),
  chooser_html, notes_html, '
</main></body></html>')

html_path <- file.path(out_dir, "we-do-comparison.html")
writeLines(page, html_path, useBytes = TRUE)
cat("\nWrote", html_path, "and", file.path(out_dir, "we-do-comparison.csv"), "\n")
