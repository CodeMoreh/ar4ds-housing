################################################################################
# Title:        02_spec_curve.R
# Purpose:      The curve of the claim: every specification of the menu
#               fitted once, with a randomisation test of each as the check.
# Reads:        data/housing_emails.csv
# Writes:       data/spec_curve.csv
# Author:       Claude for CM
# Last updated: 2026-11-20
################################################################################

source("R/_tools.R")

housing <- readr::read_csv("data/housing_emails.csv", show_col_types = FALSE)

# The randomisation test of each specification, stored beside the test of its
# model: the Hispanic names reshuffled among the analysed emails by complete
# random assignment (ri2; Gerber and Green 2012, chapter 3), and the model
# refitted. ri2 refits the linear model without inverse probability weights,
# which would change the covariate-adjusted coefficient, and the logit through
# a test function. statmod::permp() gives a p-value that is never zero
# (Phipson and Smyth 2010).
N_DRAWS <- 1999

curve <- tidyr::expand_grid(!!!SPEC_AXES) |>
  purrr::pmap(\(comparison, population, uncoded, model, adjust)
              fit_spec(housing, comparison, population, uncoded, model, adjust)) |>
  dplyr::bind_rows() |>
  dplyr::mutate(spec_id = dplyr::row_number(), .before = 1)

p_ri <- curve |>
  purrr::pmap_dbl(\(spec_id, comparison, population, uncoded, model, adjust, coef, ...) {
    set.seed(20261025 + spec_id)
    terms <- ADJUST_TERMS[[adjust]]
    frame <- spec_frame(housing, comparison, population, uncoded) |>
      dplyr::select("y", "hisp", dplyr::all_of(terms)) |>
      stats::na.omit()
    form <- stats::reformulate(c("hisp", terms), response = "y")
    design <- randomizr::declare_ra(N = nrow(frame), m = sum(frame$hisp))
    ri <- if (model == "lpm") {
      ri2::conduct_ri(form, assignment = "hisp", declaration = design, sharp_hypothesis = 0,
                      IPW = FALSE, data = frame, sims = N_DRAWS)
    } else {
      ri2::conduct_ri(test_function = \(d) stats::coef(stats::glm(form, family = stats::binomial(), data = d))[["hisp"]],
                      assignment = "hisp", declaration = design, sharp_hypothesis = 0,
                      data = frame, sims = N_DRAWS)
    }
    stopifnot(abs(ri$sims_df$est_obs[1] - coef) < 1e-9)
    extreme <- summary(ri)$two_tailed_p_value * N_DRAWS
    statmod::permp(round(extreme), nperm = N_DRAWS, n1 = sum(frame$hisp), n2 = sum(frame$hisp == 0))
  })

curve <- curve |>
  dplyr::mutate(
    p_ri = p_ri,
    supports = b_pp < 0,
    sig = p < 0.05,
    is_reference = comparison == "white" & population == "replies" & uncoded == "drop" &
      model == "lpm" & adjust == "none"
  ) |>
  # the 95% interval is printed by the helpers from a live fit, not stored
  dplyr::select(-"ci_low", -"ci_high")

stopifnot(nrow(curve) == 64, sum(curve$is_reference) == 1)

readr::write_csv(curve, "data/spec_curve.csv")
