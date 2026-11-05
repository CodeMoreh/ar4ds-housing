################################################################################
# Title:        Bayesian models of the housing-audit case
# Purpose:      The fits behind the Bayesian estimation module. A binomial
#               model of the greetings by name among the coded replies to
#               Hispanic and white names, fitted with brms on the counts of
#               the original audit and of the SCORE replication: the priors
#               alone (prior predictive check), the original audit under a
#               weakly informative and a sceptical prior for the gap, the
#               replication alone and with the posterior of the original as
#               its prior, and both studies in one model, with a common gap
#               and with a gap for each study. The gaps are taken to
#               percentage points with marginaleffects, the prior
#               sensitivity comes from priorsense, and only summaries and a
#               thinned set of draws leave the script.
# Reads:        cases/housing/data/housing_audit.csv (the original replies),
#               cases/housing/data/display_replication.csv (the replication,
#               from which the counts of each group are recovered)
# Writes:       companion/_model-outputs/bayes_audit_counts.csv
#               companion/_model-outputs/bayes_audit_draws.csv
#               companion/_model-outputs/bayes_audit_summary.csv
#               companion/_model-outputs/bayes_audit_diagnostics.csv
#               companion/_model-outputs/bayes_audit_sensitivity.csv
#               companion/_model-outputs/bayes_audit_ppc.csv
#               (and the fitted models as fit_*.rds, which git ignores)
# Author:       Claude for CM
# Last updated: 2026-11-05
################################################################################

set.seed(20261105)
out <- "companion/_model-outputs/"

# The original audit: the coded replies to Hispanic and white names, the rows
# of the reference specification of the curve (white, replies, drop)
original <- readr::read_csv("cases/housing/data/housing_audit.csv", show_col_types = FALSE) |>
  datawizard::data_filter(reply == 1, !is.na(named), group %in% c("white", "hispanic")) |>
  datawizard::data_modify(hisp = as.integer(group == "hispanic")) |>
  datawizard::data_summary(k = sum(named), n = length(named), by = "hisp") |>
  datawizard::data_modify(study = "original")

# The replication publishes no person-level file that the course may copy, and
# display_replication.csv holds the shares and the total of its replies but not
# the size of each group. The only split of the 1,484 replies into whole
# numbers of greetings at both shares is recovered here and checked against
# the facts of the case (721 replies to Hispanic and 763 to white aliases).
replies_row <- readr::read_csv("cases/housing/data/display_replication.csv", show_col_types = FALSE) |>
  datawizard::data_filter(population == "replies", authorities == "all")
split <- tibble::tibble(n_hisp = seq_len(replies_row$n - 1)) |>
  datawizard::data_modify(
    n_white = replies_row$n - n_hisp,
    k_hisp = replies_row$rate_hisp / 100 * n_hisp,
    k_white = replies_row$rate_comp / 100 * n_white
  ) |>
  datawizard::data_filter(abs(k_hisp - round(k_hisp)) < 1e-6, abs(k_white - round(k_white)) < 1e-6)
stopifnot(nrow(split) == 1, split$n_hisp == 721, split$n_white == 763)
replication <- tibble::tibble(hisp = c(0L, 1L), k = round(c(split$k_white, split$k_hisp)),
                              n = c(split$n_white, split$n_hisp), study = "replication")

counts <- dplyr::bind_rows(original, replication) |>
  datawizard::data_modify(hisp = as.integer(hisp), k = as.integer(k), n = as.integer(n),
                          study = factor(study, levels = c("original", "replication")))
stopifnot(identical(counts$k, c(107L, 77L, 400L, 378L)), identical(counts$n, c(175L, 187L, 763L, 721L)))
readr::write_csv(counts, paste0(out, "bayes_audit_counts.csv"))
orig_counts <- datawizard::data_filter(counts, study == "original")
repl_counts <- datawizard::data_filter(counts, study == "replication")

# Priors on the log-odds scale. The intercept is the log-odds of a greeting by
# name for a white name; normal(0, 1.5) is nearly flat on the probability
# scale (McElreath 2020, p. 328). The gap: weakly informative, normal(0, 1),
# against sceptical, normal(0, 0.25), which keeps 95% of its mass within about
# 12 points of no gap. `0 + Intercept` keeps the intercept on the scale of the
# white names rather than of the centred predictor.
prior_weak <- c(brms::prior(normal(0, 1.5), class = "b", coef = "Intercept"),
                brms::prior(normal(0, 1), class = "b", coef = "hisp"))
prior_sceptical <- c(brms::prior(normal(0, 1.5), class = "b", coef = "Intercept"),
                     brms::prior(normal(0, 0.25), class = "b", coef = "hisp"))

fit_prior_weak <- brms::brm(k | trials(n) ~ 0 + Intercept + hisp, family = stats::binomial(),
                            data = orig_counts, prior = prior_weak, sample_prior = "only",
                            chains = 4, iter = 2000, seed = 20261105, backend = "cmdstanr", refresh = 0,
                            file = paste0(out, "fit_prior_weak"), file_refit = "on_change")
fit_prior_sceptical <- brms::brm(k | trials(n) ~ 0 + Intercept + hisp, family = stats::binomial(),
                                 data = orig_counts, prior = prior_sceptical, sample_prior = "only",
                                 chains = 4, iter = 2000, seed = 20261105, backend = "cmdstanr", refresh = 0,
                                 file = paste0(out, "fit_prior_sceptical"), file_refit = "on_change")
fit_original_weak <- brms::brm(k | trials(n) ~ 0 + Intercept + hisp, family = stats::binomial(),
                               data = orig_counts, prior = prior_weak,
                               chains = 4, iter = 2000, seed = 20261105, backend = "cmdstanr", refresh = 0,
                               file = paste0(out, "fit_original_weak"), file_refit = "on_change")
fit_original_sceptical <- brms::brm(k | trials(n) ~ 0 + Intercept + hisp, family = stats::binomial(),
                                    data = orig_counts, prior = prior_sceptical,
                                    chains = 4, iter = 2000, seed = 20261105, backend = "cmdstanr", refresh = 0,
                                    file = paste0(out, "fit_original_sceptical"), file_refit = "on_change")

# The replication alone, under the weakly informative prior, and with the
# posterior of the original gap as the prior of its gap. The posterior is
# carried over as a normal distribution with its mean and standard deviation,
# an approximation that is close for a log-odds coefficient at this size; the
# intercept keeps the weak prior, because the names and the year are new.
carried <- posterior::summarise_draws(brms::as_draws_df(fit_original_weak, variable = "b_hisp"), "mean", "sd")
prior_updated <- c(brms::prior(normal(0, 1.5), class = "b", coef = "Intercept"),
                   brms::set_prior(sprintf("normal(%.4f, %.4f)", carried$mean, carried$sd),
                                   class = "b", coef = "hisp"))
fit_replication_alone <- brms::brm(k | trials(n) ~ 0 + Intercept + hisp, family = stats::binomial(),
                                   data = repl_counts, prior = prior_weak,
                                   chains = 4, iter = 2000, seed = 20261105, backend = "cmdstanr", refresh = 0,
                                   file = paste0(out, "fit_replication_alone"), file_refit = "on_change")
fit_replication_updated <- brms::brm(k | trials(n) ~ 0 + Intercept + hisp, family = stats::binomial(),
                                     data = repl_counts, prior = prior_updated,
                                     chains = 4, iter = 2000, seed = 20261105, backend = "cmdstanr", refresh = 0,
                                     file = paste0(out, "fit_replication_updated"), file_refit = "on_change")

# Both studies in one model: a share of greetings for the white names of each
# study, and either one gap for both or a gap for each
fit_joint_common <- brms::brm(k | trials(n) ~ 0 + study + hisp, family = stats::binomial(),
                              data = counts,
                              prior = c(brms::prior(normal(0, 1.5), class = "b"),
                                        brms::prior(normal(0, 1), class = "b", coef = "hisp")),
                              chains = 4, iter = 2000, seed = 20261105, backend = "cmdstanr", refresh = 0,
                              file = paste0(out, "fit_joint_common"), file_refit = "on_change")
fit_joint_separate <- brms::brm(k | trials(n) ~ 0 + study + study:hisp, family = stats::binomial(),
                                data = counts,
                                prior = c(brms::prior(normal(0, 1.5), class = "b"),
                                          brms::set_prior("normal(0, 1)", class = "b", coef = "studyoriginal:hisp"),
                                          brms::set_prior("normal(0, 1)", class = "b", coef = "studyreplication:hisp")),
                                chains = 4, iter = 2000, seed = 20261105, backend = "cmdstanr", refresh = 0,
                                file = paste0(out, "fit_joint_separate"), file_refit = "on_change")

single <- list(prior_weak = fit_prior_weak, prior_sceptical = fit_prior_sceptical,
               original_weak = fit_original_weak, original_sceptical = fit_original_sceptical,
               replication_alone = fit_replication_alone, replication_updated = fit_replication_updated)
joint <- list(joint_common = fit_joint_common, joint_separate = fit_joint_separate)
study_grid <- tibble::tibble(study = factor(c("original", "replication"), levels = c("original", "replication")),
                         hisp = 0L, n = 1L)

# The gap in percentage points, draw by draw: the predicted share of greetings
# with a Hispanic name minus that with a white name, on one trial (n = 1) so
# that the prediction is a probability rather than a count
gaps <- dplyr::bind_rows(
  purrr::imap(single, \(fit, name) {
    marginaleffects::avg_comparisons(fit, variables = "hisp", newdata = tibble::tibble(hisp = 0L, n = 1L)) |>
      marginaleffects::get_draws(shape = "long") |>
      tibble::as_tibble() |>
      dplyr::transmute(model = name, quantity = "gap", value = 100 * draw, draw = as.integer(as.character(drawid)))
  }) |> purrr::list_rbind(),
  purrr::imap(joint, \(fit, name) {
    marginaleffects::avg_comparisons(fit, variables = "hisp", newdata = study_grid, by = "study") |>
      marginaleffects::get_draws(shape = "long") |>
      tibble::as_tibble() |>
      dplyr::transmute(model = name, quantity = paste0("gap_", study), value = 100 * draw, draw = as.integer(as.character(drawid)))
  }) |> purrr::list_rbind(),
  # the replication gap minus the original gap, in the model with a gap for each
  marginaleffects::avg_comparisons(fit_joint_separate, variables = "hisp", newdata = study_grid, by = "study",
                                   hypothesis = "b2 - b1 = 0") |>
    marginaleffects::get_draws(shape = "long") |>
    tibble::as_tibble() |>
    dplyr::transmute(model = "joint_separate", quantity = "difference", value = 100 * draw, draw = as.integer(as.character(drawid))),
  # the share of greetings for the white names that the priors imply
  purrr::imap(single[c("prior_weak", "prior_sceptical")], \(fit, name) {
    marginaleffects::avg_predictions(fit, newdata = tibble::tibble(hisp = 0L, n = 1L)) |>
      marginaleffects::get_draws(shape = "long") |>
      tibble::as_tibble() |>
      dplyr::transmute(model = name, quantity = "white_share", value = 100 * draw, draw = as.integer(as.character(drawid)))
  }) |> purrr::list_rbind(),
  # the coefficient of the Hispanic names on the log-odds scale
  purrr::imap(single, \(fit, name) {
    tibble::tibble(model = name, quantity = "coef", draw = seq_len(brms::ndraws(fit)),
                   value = brms::as_draws_df(fit, variable = "b_hisp")$b_hisp)
  }) |> purrr::list_rbind()
)

# Posterior summaries: median and 95% equal-tailed interval, the probability of
# direction, the probability that the gap exceeds 5 and 10 points in the
# direction of its median, and the share of the distribution within 5 points
# of no gap (bayestestR)
summary_tab <- gaps |>
  datawizard::data_summary(
    median = stats::median(value), mean = mean(value), sd = stats::sd(value),
    q025 = stats::quantile(value, 0.025), q05 = stats::quantile(value, 0.05),
    q95 = stats::quantile(value, 0.95), q975 = stats::quantile(value, 0.975),
    pd = as.numeric(bayestestR::p_direction(value)),
    p_beyond_5 = as.numeric(bayestestR::p_significance(value, threshold = 5)),
    p_beyond_10 = as.numeric(bayestestR::p_significance(value, threshold = 10)),
    within_5 = as.numeric(bayestestR::rope(value, range = c(-5, 5), ci = 1)),
    by = c("model", "quantity")
  ) |>
  dplyr::mutate(dplyr::across(dplyr::where(is.double), \(x) signif(x, 6)))
readr::write_csv(summary_tab, paste0(out, "bayes_audit_summary.csv"))

# A thinned set of draws of the gaps and the white share, one in eight, for the
# density figures of the module
gaps |>
  datawizard::data_filter(draw %% 8 == 0, quantity != "coef") |>
  datawizard::data_modify(value = round(value, 2)) |>
  readr::write_csv(paste0(out, "bayes_audit_draws.csv"))

# Computation: the largest R-hat and the smallest bulk and tail effective
# sample sizes of the coefficients, divergent transitions and the deepest tree
fits <- c(single, joint)
diagnostics <- purrr::imap(fits, \(fit, name) {
  conv <- posterior::summarise_draws(brms::as_draws_df(fit, variable = "^b_", regex = TRUE),
                                     "rhat", "ess_bulk", "ess_tail")
  nuts <- brms::nuts_params(fit)
  tibble::tibble(model = name, draws = brms::ndraws(fit), max_rhat = max(conv$rhat),
                 min_ess_bulk = min(conv$ess_bulk), min_ess_tail = min(conv$ess_tail),
                 divergences = sum(nuts$Value[nuts$Parameter == "divergent__"]),
                 max_treedepth = max(nuts$Value[nuts$Parameter == "treedepth__"]))
}) |>
  purrr::list_rbind() |>
  dplyr::mutate(dplyr::across(dplyr::where(is.double), \(x) signif(x, 6)))
readr::write_csv(diagnostics, paste0(out, "bayes_audit_diagnostics.csv"))

# Prior sensitivity by power-scaling (Kallioinen et al.): how far the posterior
# of each gap coefficient moves when the prior or the likelihood is raised to
# a power near 1, without refitting
sens_vars <- list(original_weak = "b_hisp", original_sceptical = "b_hisp", replication_alone = "b_hisp",
                  replication_updated = "b_hisp", joint_common = "b_hisp",
                  joint_separate = c("b_studyoriginal:hisp", "b_studyreplication:hisp"))
sensitivity <- purrr::imap(sens_vars, \(vars, name) {
  priorsense::powerscale_sensitivity(fits[[name]], variable = vars) |>
    tibble::as_tibble() |>
    dplyr::transmute(model = name, variable, prior = signif(prior, 4), likelihood = signif(likelihood, 4),
                     diagnosis)
}) |>
  purrr::list_rbind()
readr::write_csv(sensitivity, paste0(out, "bayes_audit_sensitivity.csv"))

# Posterior predictive check of the two joint models: the share of greetings
# in each of the four cells, observed and in replicated data (90% interval)
ppc <- purrr::imap(joint, \(fit, name) {
  yrep <- brms::posterior_predict(fit)
  # dplyr, because datawizard evaluates in a fresh environment that cannot see yrep
  counts |>
    dplyr::mutate(
      model = name,
      observed = 100 * k / n,
      rep_median = purrr::map_dbl(seq_along(n), \(j) 100 * stats::median(yrep[, j] / n[j])),
      rep_q05 = purrr::map_dbl(seq_along(n), \(j) 100 * stats::quantile(yrep[, j] / n[j], 0.05)),
      rep_q95 = purrr::map_dbl(seq_along(n), \(j) 100 * stats::quantile(yrep[, j] / n[j], 0.95))
    )
}) |>
  purrr::list_rbind() |>
  dplyr::mutate(dplyr::across(dplyr::where(is.double), \(x) signif(x, 6)))
readr::write_csv(ppc, paste0(out, "bayes_audit_ppc.csv"))
