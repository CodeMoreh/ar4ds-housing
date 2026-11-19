################################################################################
# Title:        06_replication.R
# Purpose:      The de-identified data of the SCORE replication as plain CSV,
#               and the replication on the scale of the course: the gap in
#               greetings by name between Hispanic and white aliases in the new
#               experiment, under the choices of the menu that its data allow, and
#               its mark on the curve of the claim.
# Reads:        data-raw/score_replication/Audit_Deidentified.dta when it is
#               present, otherwise the committed data/housing_replication.csv;
#               data/reference_marks.csv
# Writes:       data/housing_replication.csv, data/display_replication.csv,
#               data/reference_marks.csv (the SCORE row)
# Author:       Claude for CM
# Last updated: 2026-11-19
################################################################################

source("R/_tools.R")

# The replication team published the file on the OSF (osf.io/xseqg, folder
# "Public Data") without a licence, and CM treats it as openly available
# (19 November 2026). The original is kept in the data hub, in "!REPLICATION
# DATA/Einstein, Glick (2017) Does race affect access to government services",
# with a copy in data-raw/score_replication/ (gitignored, as every .dta is).
# The CSV keeps the column names of the source and turns its value labels into
# their numeric codes, so that the stages, the pages and the workspace need
# neither the .dta nor the OSF. It holds 2,717 delivered emails from four male
# aliases (two Hispanic, two white), no Black aliases; County = 1 marks
# authorities run by counties, which the replication left out to match Table 1
# of the original.
RAW <- "data-raw/score_replication/Audit_Deidentified.dta"
if (file.exists(RAW)) {
  haven::read_dta(RAW) |>
    dplyr::mutate(dplyr::across(dplyr::where(haven::is.labelled), \(x) as.numeric(x))) |>
    haven::zap_label() |>
    haven::zap_formats() |>
    readr::write_csv("data/housing_replication.csv", na = "")
}

repl <- readr::read_csv("data/housing_replication.csv", show_col_types = FALSE) |>
  datawizard::data_select(c(hisp = "HispanicName", reply = "Reply", named = "Friendly", county = "County"))

stopifnot(nrow(repl) == 2717, sum(repl$reply) == 1484, all(repl$named <= repl$reply))

# The two populations of the menu; there are no uncoded replies and no Black
# aliases, so the comparison is white names under every option. The gap is a
# linear probability model with HC2 errors from parameters and sandwich.
gap <- function(data, population, authorities) {
  frame <- if (population == "replies") datawizard::data_filter(data, reply == 1) else data
  fit <- stats::lm(named ~ hisp, data = frame)
  est <- parameters::model_parameters(fit, vcov = "HC2") |>
    datawizard::data_filter(Parameter == "hisp")
  tibble::tibble(population = population, authorities = authorities,
                 b_pp = 100 * est$Coefficient, se_pp = 100 * est$SE, stat_type = "t", stat = est$t,
                 df = est$df_error, p = est$p, n = nrow(frame),
                 rate_hisp = 100 * mean(frame$named[frame$hisp == 1]),
                 rate_comp = 100 * mean(frame$named[frame$hisp == 0]))
}

replication <- tidyr::expand_grid(population = c("replies", "all"), authorities = c("all", "sub-county")) |>
  purrr::pmap(\(population, authorities) gap(if (authorities == "all") repl else datawizard::data_filter(repl, county == 0),
                                             population, authorities)) |>
  dplyr::bind_rows()
readr::write_csv(replication, "data/display_replication.csv")

# The mark: the raw gap among all replies, the analogue of the reference
# specification of the curve (white names, replies, no covariates)
ref <- datawizard::data_filter(replication, population == "replies" & authorities == "all")
marks <- readr::read_csv("data/reference_marks.csv", show_col_types = FALSE) |>
  datawizard::data_filter(id != "SCORE") |>
  dplyr::bind_rows(tibble::tibble(
    id = "SCORE", label = "SCORE replication (new experiment, 2020)", statistic_type = "t",
    statistic = ref$stat, n = ref$n, b_pp = ref$b_pp, on_chart = TRUE,
    note = "New data: 3,050 authorities emailed by four male aliases, two Hispanic and two white. Placed by the raw gap among all replies, computed by the course from the de-identified data on the OSF (osf.io/xseqg)."
  ))
readr::write_csv(marks, "data/reference_marks.csv", na = "")
