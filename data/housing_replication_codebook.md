# Codebook: `housing_replication.csv`

The data of the SCORE replication of "Does Race Affect Access to Government Services? An Experiment Exploring Street-Level Bureaucrats and Access to Public Housing" (Einstein and Glick 2017), in the form of the course file `housing_emails.csv` ([codebook](housing_emails_codebook.md)): 2,717 rows, one per delivered email, and 12 columns, named as in the course file wherever the new experiment recorded the same thing. Task 6 fits the declared specification on this file. The replication was a preregistered audit experiment, run in 2020, which emailed 3,050 public housing authorities listed by HUD under four male aliases, Joe Garcia and Michael Hernandez (Hispanic) and John Ryan and Nicholas Smith (white). Its team published the data as `Audit_Deidentified.dta`, with a dictionary, in the component "Data" of the OSF project of the replication ([osf.io/xseqg](https://osf.io/xseqg/), folder "Public Data"), without a stated licence. The file is written by `R/06_replication.R`, which renames the columns and writes the terciles as words; it changes no value and no row. The source records whether the alias of each email was Hispanic, but not which of the four aliases signed it.

## Variables

| Variable | Description | Source column |
|:--|:--|:--|
| `email_id` | The row number of the email in the source file, 1 to 2,717 | – |
| `group` | The group that the alias was meant to indicate: `hispanic` (1,357 emails) or `white` (1,360) | `HispanicName` |
| `reply` | 1 if the authority replied (1,484: 763 replies to white and 721 to Hispanic aliases), 0 if it did not (1,233) | `Reply` |
| `reply24` | Replies only: 1 if the reply came within 24 hours (405), 0 if later (1,079); missing for every email without a reply | `Reply24Hours` |
| `days_to_reply` | Replies only: the number of days until the reply, from 0 to 8; missing for every email without a reply, which the source codes as 8 | `DaysToReply` |
| `named` | Replies only: 1 if the reply used the first or the last name of the sender, the outcome described by the dictionary as "As defined by Einstein and Glick" (400 replies to white and 378 to Hispanic aliases), 0 if not; missing for every email without a reply | `Friendly` |
| `county` | 1 if the authority is run by a county (379 emails), 0 if it serves a place (2,338); the replication left the county authorities out of its models with covariates, to match Table 1 of the original | `County` |
| `geography` | The type of locality for which the authority is responsible: `City` (2,227 emails), `County` (379), `Town` (83), `Village` (26), `Borough` (1) and `To` (1), the last probably a truncated `Town` | `Geography` |
| `black_third` | The tercile of the locality on its percentage of Black residents, against the other localities of the study: `lower`, `middle` or `top` | `DI_Black` |
| `hispanic_third` | The same on the percentage of Hispanic residents | `DI_Hispanic` |
| `pop_third` | The same on the population | `DI_Population` |
| `poverty_third` | The same on the poverty rate; missing for 2 emails | `DI_Poverty` |

The source codes the terciles 0, 1 and 2, which the file writes as `lower`, `middle` and `top`, the words of the thirds of the course file. Compared with the course file, the file holds no Black and no female names, no indicator of a hard-to-find address (`hard_email`), no reply without a greeting code and no bounced email, and its terciles were computed by the replication team for the localities of the new experiment.
