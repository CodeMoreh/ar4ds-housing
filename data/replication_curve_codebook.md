# Codebook: `replication_curve.csv`

The curve of the claim on the data of the SCORE replication, `housing_replication.csv` ([codebook](housing_replication_codebook.md)): 64 rows, one for each specification of the curve of the original data, `spec_curve.csv` ([codebook](spec_curve_codebook.md)), with the estimate that the same specification gives on the new data. The file is written by `R/06_replication.R` with the course estimator, `fit_spec()`, and Task 6 and the class chart read it.

The new experiment had no Black names, no reply without a greeting code and no indicator of a hard-to-find address, so each specification is translated to its design: the comparison is with white names under both options of `comparison`, the two options of `uncoded` give the same rows, and the adjustment sets leave out `hard_email`, which makes `email` the same as `none`. The 64 specifications therefore collapse to 12, each named by `rep_spec`, and the rows of one translated specification carry identical estimates. Every authority is kept, the county-run ones included, as in the preregistered analysis of the replication.

## Variables

| Variable | Description |
|:--|:--|
| `comparison`, `population`, `uncoded`, `model`, `adjust` | The five decisions of the specification of the curve, as in `spec_curve.csv` |
| `rep_spec` | The translated specification, as the three decisions that still differ on the new data: `population`, `model` and the adjustment, with `email` written as `none` |
| `rep_rank` | The rank of the translated specification among the 12, from the most negative estimate (1) to the least negative (12) |
| `b_pp` | The estimate on the new data: the difference between Hispanic and white aliases in the share greeted by name, in percentage points; below zero is the direction of the claim |
| `se_pp`, `ci_low`, `ci_high` | Its standard error and 95% interval, in percentage points: HC2 errors and a t interval for the linear probability model, a delta-method error and a normal interval for the average marginal effect of the logit |
| `stat_type`, `stat`, `df`, `p` | The test of the model: `t` with its degrees of freedom for the linear probability model, `z` for the logit (no `df`), and its two-sided p-value |
| `n`, `n_hisp`, `n_comp` | The analysed emails, all of them and by group |
| `rate_hisp`, `rate_comp` | The shares greeted by name, in per cent, for the Hispanic and the white aliases |

The 12 estimates run from −1.56 to +0.47 points, and none is significant at 5%: the smallest p-value is 0.37.
