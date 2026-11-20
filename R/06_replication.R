################################################################################
# Title:        06_replication.R
# Purpose:      The data of the replication in the SCORE replicability study
#               in the form of the analysis file, the replication on the workshop's scale, its mark on
#               the curve of the claim, and the curve of the claim on the new
#               data: every specification of the curve, translated to the design
#               of the new experiment and fitted on its data.
# Reads:        data-raw/score_replication/Audit_Deidentified.dta when it is
#               present, otherwise the committed data/housing_replication.csv;
#               data/spec_curve.csv, data/reference_marks.csv
# Writes:       data/housing_replication.csv, data/display_replication.csv,
#               data/replication_curve.csv, data/reference_marks.csv (the
#               SCORE row)
# Author:       Claude for CM
# Last updated: 2026-11-20
################################################################################

source("R/_tools.R")

# The file of the replication team (osf.io/xseqg, folder "Public Data"), with
# no licence and treated by CM as openly available (19 November 2026). The
# original is in the data hub ("!REPLICATION DATA/Einstein, Glick (2017) Does
# race affect access to government services"), a copy in
# data-raw/score_replication/ (gitignored). The CSV takes the column names of
# housing_emails.csv wherever the new experiment recorded the same thing, so
# that fit_spec() reads it as it reads the original file; the terciles of the
# source (0, 1, 2) become the lower, middle and top thirds.
RAW <- "data-raw/score_replication/Audit_Deidentified.dta"
if (file.exists(RAW)) {
  thirds <- c("lower", "middle", "top")
  haven::read_dta(RAW) |>
    haven::zap_labels() |>
    dplyr::transmute(
      email_id = dplyr::row_number(),
      group = dplyr::if_else(HispanicName == 1, "hispanic", "white"),
      reply = Reply,
      reply24 = dplyr::if_else(Reply == 1, Reply24Hours, NA_real_),
      days_to_reply = dplyr::if_else(Reply == 1, DaysToReply, NA_real_),
      named = dplyr::if_else(Reply == 1, Friendly, NA_real_),
      county = County,
      geography = Geography,
      black_third = thirds[DI_Black + 1],
      hispanic_third = thirds[DI_Hispanic + 1],
      pop_third = thirds[DI_Population + 1],
      poverty_third = thirds[DI_Poverty + 1]
    ) |>
    readr::write_csv("data/housing_replication.csv", na = "")
}

replication <- readr::read_csv("data/housing_replication.csv", show_col_types = FALSE)
stopifnot(nrow(replication) == 2717, sum(replication$reply) == 1484,
          sum(replication$named, na.rm = TRUE) == 778, !anyNA(replication$named[replication$reply == 1]))

# The workshop's reference comparison on the new data – white names, a
# linear probability model without covariates – among the replies and among
# all emails, for every authority and for those not run by counties, which the
# replication left out of its models with covariates to match Table 1 of the
# original
display <- tidyr::expand_grid(population = c("replies", "all"), authorities = c("all", "sub-county")) |>
  purrr::pmap(\(population, authorities) {
    rows <- if (authorities == "all") replication else datawizard::data_filter(replication, county == 0)
    fit_spec(rows, population = population) |>
      dplyr::mutate(authorities = .env$authorities)
  }) |>
  dplyr::bind_rows() |>
  datawizard::data_select(c("population", "authorities", "b_pp", "se_pp", "stat_type", "stat", "df", "p",
                            "n", "rate_hisp", "rate_comp"))
readr::write_csv(display, "data/display_replication.csv")

# The mark: the raw gap among all replies, the analogue of the reference
# specification of the curve (white names, replies, no covariates)
ref <- datawizard::data_filter(display, population == "replies" & authorities == "all")
marks <- readr::read_csv("data/reference_marks.csv", show_col_types = FALSE) |>
  datawizard::data_filter(id != "SCORE") |>
  dplyr::bind_rows(tibble::tibble(
    id = "SCORE", label = "Replication, 2020", statistic_type = "t",
    statistic = ref$stat, n = ref$n, b_pp = ref$b_pp, on_chart = TRUE,
    note = "New data: 3,050 authorities emailed by four male aliases, two Hispanic and two white. Placed by the raw gap among all replies, computed by the workshop from the de-identified data of the replication (osf.io/xseqg), kept as housing_replication.csv."
  ))
readr::write_csv(marks, "data/reference_marks.csv", na = "")

# The curve of the claim on the new data. The new experiment had no Black
# names, no reply without a greeting code and no hard_email, so each
# specification is translated: the comparison is with white names, the two
# rules for uncoded replies coincide, and fit_spec() drops hard_email. The 64
# specifications collapse to 12 (rep_spec), ranked from the most negative
# estimate (rep_rank). Every authority is kept, county-run ones included, as
# in the preregistered analysis of the replication (CM, 19 November 2026).
on_new_data <- readr::read_csv("data/spec_curve.csv", show_col_types = FALSE) |>
  datawizard::data_select(c("comparison", "population", "uncoded", "model", "adjust")) |>
  purrr::pmap(\(comparison, population, uncoded, model, adjust)
              fit_spec(replication, comparison, population, uncoded, model, adjust)) |>
  dplyr::bind_rows() |>
  datawizard::data_modify(rep_spec = sprintf("population=%s model=%s adjust=%s", population, model,
                                             dplyr::if_else(adjust == "email", "none", adjust)))

spread <- datawizard::data_summary(on_new_data, spread = max(b_pp) - min(b_pp), by = "rep_spec")
ranks <- on_new_data |>
  datawizard::data_filter(!duplicated(rep_spec)) |>
  datawizard::data_arrange(c("b_pp", "rep_spec"))
stopifnot(nrow(ranks) == 12, max(spread$spread) < 1e-9)

replication_curve <- on_new_data |>
  datawizard::data_modify(rep_rank = match(rep_spec, ranks$rep_spec)) |>
  datawizard::data_select(c("comparison", "population", "uncoded", "model", "adjust", "rep_spec", "rep_rank",
                            "b_pp", "se_pp", "ci_low", "ci_high", "stat_type", "stat", "df", "p", "n",
                            "n_hisp", "n_comp", "rate_hisp", "rate_comp"))
readr::write_csv(replication_curve, "data/replication_curve.csv")
