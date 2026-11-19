# Codebook: `housing_replication.csv`

The de-identified data of the SCORE replication of "Does Race Affect Access to Government Services? An Experiment Exploring Street-Level Bureaucrats and Access to Public Housing" (Einstein and Glick 2017), as a plain CSV with the column names of the source: 2,717 rows, one per delivered email, and 11 columns. The replication was a preregistered audit experiment, run in 2020, which emailed 3,050 public housing authorities listed by HUD under four male aliases, Joe Garcia and Michael Hernandez (Hispanic) and John Ryan and Nicholas Smith (white). Its team published the file as `Audit_Deidentified.dta`, with a dictionary, in the component "Data" of the OSF project of the replication ([osf.io/xseqg](https://osf.io/xseqg/), folder "Public Data"), without a stated licence. The file is written by `R/06_replication.R`, which turns the Stata value labels into their numeric codes and drops the variable labels and formats; it changes no value and no row. The file records whether the alias of each email was Hispanic, but not which of the four aliases signed it.

## Columns

| Column | Description |
|:--|:--|
| `Reply` | 1 if the email received a reply, 0 if not: 1,484 replies, 763 to white and 721 to Hispanic aliases |
| `Friendly` | 1 if the reply used the first or the last name of the sender, the outcome that the dictionary describes as "As defined by Einstein and Glick", and 0 otherwise, including every email without a reply: 400 of the replies to white aliases and 378 of the replies to Hispanic aliases |
| `Reply24Hours` | 1 if the reply came within 24 hours (405 replies), 0 otherwise, including every email without a reply |
| `DaysToReply` | the number of days until the reply, from 0 to 8; 8 for every email without a reply, and for 10 replies |
| `HispanicName` | 1 if the email was signed by a Hispanic alias (1,357 emails), 0 if by a white alias (1,360) |
| `Geography` | the type of locality for which the authority is responsible: `City` (2,227 emails), `County` (379), `Town` (83), `Village` (26), `Borough` (1) and `To` (1), the last probably a truncated `Town` |
| `County` | 1 if the authority is run by a county (379 emails), 0 if it serves a place (2,338); the replication left the county authorities out of its models with covariates, to match Table 1 of the original |
| `DI_Black` | the tercile of the locality on its percentage of Black residents, against the other localities of the study: 0 low, 1 medium, 2 high |
| `DI_Hispanic` | the same on the percentage of Hispanic residents |
| `DI_Poverty` | the same on the poverty rate; empty for two emails |
| `DI_Population` | the same on the population |

Compared with the public file of the original authors, `housing_original.csv` ([codebook](housing_original_codebook.md)), the file holds no Black and no female names, no indicator of a hard-to-find address and no reply without a greeting code, and it counts every delivered email, with `Friendly` at 0 where no reply came. Its terciles run from 0 to 2, where the thirds of the original file run from 1 to 3.
