# AR4DS – Housing and racial bias

The site of the Housing and racial bias case study of Applied Replication for Data Skills (AR4DS), a course in reproduction, robustness and replication in R taught on published claims. Facilitator: [Chris Moreh](https://chrismoreh.com). The site deploys to GitHub Pages at <https://codemoreh.github.io/ar4ds-housing/>; the other case studies and the pages that every case study shares are on the [AR4DS site](https://codemoreh.github.io/ar4ds/).

The case study is a field experiment in which emails that differed only in the name that signed them were sent to public housing authorities in the United States (Einstein and Glick, 2017, *American Journal of Political Science*), with the claim that Hispanic senders were greeted by name less often. Five analysts reanalysed the claim for the robustness study of SCORE (Alipourfard et al., 2021), known as Multi100 and published in *Nature* (Aczel et al., 2026), and a preregistered replication tested it with new names. The data are the public file of the original authors on the Harvard Dataverse (doi:10.7910/DVN/1HOVTU), released under CC0.

## Formats

| Format | Folder | Taught in |
|---|---|---|
| Short session, in two halves | `tracks/housing-short/` | the browser lab |
| One-day workshop, in four parts | `tracks/housing-one-day/` | the browser lab, the workspace as an option |
| Extended course, three days built around the workshop | `tracks/housing-extended/` | the workspace, with the browser lab on the day of the workshop |
| Self-study | `tracks/self-study/` | the workspace |

Each format has a docked sidebar (`_sidebar.yml`), an exercise page, part pages that lead into the content, and a slides page that embeds its deck (`slides/housing-*.qmd`, assembled from `slides/_segments/`). The run sheet of the facilitator, with the timings, is `facilitator/housing-guide.qmd`.

## Layout

| Path | What it is |
|---|---|
| `index.qmd` | The home page |
| `cases/housing/` | The background page, the browser lab, the specification menu with the decision map, the specification curve, the class results, the cheatsheet, the parts that the exercise pages of the formats share (`_exercise-*.qmd`), and `data/` with a codebook for every file |
| `tracks/` | The formats |
| `slides/` | The decks and their segments |
| `companion/` | The modules of the companion, written on the data of the case study; `_model-outputs/` holds the scripts and aggregate outputs behind them |
| `R/housing/` | The pipeline that builds the data files of the case study; `R/housing/README.md` gives the order |
| `data-raw/housing/` | The archived inputs of the pipeline |
| `resources.qmd` | Readings, records and tools |
| `_variables.yml` | Site variables and the next-delivery block |

The downloadable workspace of the case study is the repository `CodeMoreh/ar4ds-housing-workspace`, and the browser lab carries the same helper functions.

## Licence

Content is licensed [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/); the data of the case study are CC0.
