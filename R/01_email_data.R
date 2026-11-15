################################################################################
# Title:        01_email_data.R
# Purpose:      The two data files of the Housing case study: the public file of
#               the original authors as plain CSV with its own column names, and
#               the course file with readable names and the derived columns.
# Reads:        data-raw/dataverse_1HOVTU/HousingAuditAJPSFinalPublic_Unidentified.dta
# Writes:       data/housing_original.csv, data/housing_emails.csv
# Author:       Claude for CM
# Last updated: 2026-11-15
################################################################################

# CC0 replication package, Harvard Dataverse doi:10.7910/DVN/1HOVTU. The
# community variables are thirds of the 2012 ACS distributions (1 lower,
# 2 middle, 3 top) because the continuous values would identify the housing
# authorities; 14 authorities have none. The source labels HispanicEmailer
# "Hard to find email address", a copy error: it records whether the official
# who replied had a distinctively Hispanic name.
raw <- haven::read_dta("data-raw/dataverse_1HOVTU/HousingAuditAJPSFinalPublic_Unidentified.dta")

original <- raw |>
  dplyr::mutate(dplyr::across(dplyr::where(haven::is.labelled), \(x) as.numeric(x))) |>
  haven::zap_label() |>
  haven::zap_formats()
readr::write_csv(original, "data/housing_original.csv", na = "")  # r-style: keep – datawizard::data_write() writes other bytes

names_key <- tibble::tibble(
  NumberAssignment = 1:6,
  name = c("Tyrone", "Shanice", "Santiago", "Gabriela", "Brett", "Emily"),
  group = c("black", "black", "hispanic", "hispanic", "white", "white"),
  name_sex = c("male", "female", "male", "female", "male", "female")
)

housing <- original |>
  datawizard::data_modify(email_id = 1:n(), WaitListFinal = datawizard::convert_to_na(WaitListFinal, na = "")) |>
  datawizard::data_join(names_key, join = "left", by = "NumberAssignment") |>
  datawizard::data_select(c(
    "email_id", "name", "group", "name_sex",
    hard_email = "HardEmail",
    reply = "Response_Dichotomous",          # missing = the email bounced
    reply24 = "Respond24",                   # replies only
    named = "ProperName",                    # replies only; 5 replies uncoded
    hispanic_official = "HispanicEmailer",   # replies only
    waitlist = "WaitListFinal",
    white_third = "white_pop_third",
    black_third = "black_pop_third",
    hispanic_third = "hispanic_pop_third",
    pop_third = "total_pop_third",
    poverty_third = "poverty_pop_third",
    assessment_third = "assesment_third"
  )) |>
  datawizard::data_modify(
    .at = c("white_third", "black_third", "hispanic_third", "pop_third", "poverty_third", "assessment_third"),
    .modify = \(x) factor(x, levels = 1:3, labels = c("lower", "middle", "top"))
  )

stopifnot(
  nrow(housing) == 1014,
  sum(is.na(housing$reply)) == 23,
  sum(housing$reply == 1, na.rm = TRUE) == 563,
  sum(housing$reply == 1 & is.na(housing$named), na.rm = TRUE) == 5,
  all(is.na(housing$named[housing$reply %in% 0]))
)

readr::write_csv(housing, "data/housing_emails.csv", na = "")  # r-style: keep – datawizard::data_write() writes other bytes
