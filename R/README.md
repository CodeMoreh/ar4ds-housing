# The pipeline of the Housing and racial bias case study

The scripts write every data file of the case study into `data/` from three inputs: the public file of the original authors (Harvard Dataverse, doi:10.7910/DVN/1HOVTU, CC0) and the five-row extract of the record of the robustness study of SCORE (Multi100; Aczel et al. 2026), both in `data-raw/`, and the de-identified data of the SCORE replication, whose copy in `data-raw/score_replication/` comes from the data hub and which stage 06 writes to `data/housing_replication.csv`. They run from the project root, in this order; `menu_options.csv` is written by hand and read by the helpers and the decision map.

| Stage | Reads | Writes |
|---|---|---|
| `01_email_data.R` | `data-raw/dataverse_1HOVTU/HousingAuditAJPSFinalPublic_Unidentified.dta` | `housing_original.csv` (the public file as CSV, original names), `housing_emails.csv` (the course file) |
| `02_spec_curve.R` | `housing_emails.csv` | `spec_curve.csv` (the 64 specifications, each with a randomisation test of 1,999 reshuffles from ri2; the slowest stage, about ten minutes) |
| `03_reference_marks.R` | `housing_emails.csv`, `data-raw/robustness/robustness_einstein_extract.csv` | `analysts5.csv` (the five analyses refitted and checked against their recorded values), `reference_marks.csv` |
| `04_menu_deviations.R` | `spec_curve.csv` | `menu_deviations.csv` |
| `05_displays.R` | `housing_emails.csv` | `display_names.csv`, `display_outcomes.csv`, `display_subgroups.csv`, `display_ri.csv`, `display_power.csv` |
| `06_replication.R` (after 03) | `data-raw/score_replication/Audit_Deidentified.dta`, the de-identified data of the SCORE replication (osf.io/xseqg, no stated licence, which CM treats as openly available), when the file is present, and otherwise the committed `housing_replication.csv`; `reference_marks.csv` | `housing_replication.csv` (the file as CSV, original names), `display_replication.csv`, and the SCORE row of `reference_marks.csv` |
| `07_dag_answers.R` | nothing; the graphs are those of the graph cell of Task 2 in `lab.qmd` | `dag_answers.csv` (the adjustment sets and paths that dagitty gives for the graph of the cell with and without the arrow of the claim, which the browser lab prints because dagitty cannot run there) |
| `check_parity.R` | `housing_emails.csv`, `spec_curve.csv` | nothing; stops if the estimator disagrees with estimatr (the HC2 errors) or margins (the average marginal effect of the logit), or the committed curve with a fresh fit |

`_tools.R` holds the estimator that every stage sources: `fit_spec()` and its parts (`spec_frame()`, `r_robustness()`, `check_spec()`, `spec_line()`). The HC2 errors of the linear model come from parameters with sandwich, the average marginal effect of the logit and its delta-method error from marginaleffects, and the t rule of the robustness study from effectsize. The downloadable workspace and the browser lab carry the same functions verbatim; a change here must be copied into `R/spec_tools.R` of the workspace, whose local copy is the folder `ar4ds-housing-workspace` beside this site, and into the helper chunk of `lab.qmd`, and checked again with `check_parity.R`.

Dependencies: readr, dplyr, tidyr, purrr, stringr, tibble, datawizard, haven, parameters, sandwich, marginaleffects and effectsize for the stages, with ri2, randomizr and statmod for the randomisation tests; estimatr and margins for the parity check only; dagitty for stage 07.
