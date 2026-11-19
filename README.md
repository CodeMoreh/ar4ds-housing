# AR4DS – Housing and racial bias

The site of the Housing and racial bias case study of Applied Replication for Data Skills (AR4DS), a course in reproduction, robustness and replication in R taught on published claims. Facilitator: [Chris Moreh](https://chrismoreh.com). The site deploys to GitHub Pages at <https://codemoreh.github.io/ar4ds-housing/>, and the pages that it shares with the rest of the course, on the tools and on SCORE, are on the [AR4DS site](https://codemoreh.github.io/ar4ds/).

The case study is a field experiment in which emails that differed only in the name that signed them were sent to public housing authorities in the United States (Einstein and Glick, 2017, *American Journal of Political Science*), with the claim that Hispanic senders were greeted by name less often. Five analysts reanalysed the claim for the robustness study of the SCORE programme (Alipourfard et al., 2021), published in *Nature* (Aczel et al., 2026), and a preregistered replication in the replicability study of the same programme tested it with new names. The data are the public file of the original authors on the Harvard Dataverse (doi:10.7910/DVN/1HOVTU), released under CC0.

## Formats

| Format | Folder | Taught in |
|---|---|---|
| Part-day, in two halves | `tracks/short/` | its live deck, with the browser lab as the fallback |
| Full-day, in four parts | `tracks/day/` | the workspace, with the live deck showing each step |
| Self-taught, in five stages | `tracks/independent/` | the workspace |
| Multi-day, three days built around the full-day format | `tracks/long/` | the workspace, with the live deck on its second day; in the repository but out of the build |

Each format has a docked sidebar (`_sidebar.yml`), an exercise page, part pages that lead into the content, and a slides page that embeds its deck: the live decks `live/short.qmd` and `live/day.qmd`, whose slides run R in the browser, assembled from `live/_segments/`. The multi-day format, the decks of its third day (`slides/experiments.qmd`, `binary-outcomes.qmd`, `bayesian.qmd` and `report.qmd`, assembled from `slides/_segments/`) and the run sheet of the facilitator with the timings (`facilitator/guide.qmd`) stay in the repository, and the `render:` list of `_quarto.yml` keeps them out of the build until they are vetted.

## Layout

| Path | What it is |
|---|---|
| `index.qmd` | The home page |
| `background.qmd`, `menu.qmd`, `curve.qmd`, `class-results.qmd`, `lab.qmd`, `cheatsheet.qmd` | The background page, the specification menu with the decision map, the specification curve, the class results, the browser lab and the cheatsheet |
| `_includes/` | The parts that the exercise pages of the formats share (`_exercise-*.qmd`), the helpers of the browser lab and of the live decks (`_lab-helpers.qmd`, `_lab-graph.qmd`), and the HTML includes of the site |
| `data/` | The data files of the case study, with a codebook for every file |
| `tracks/` | The formats |
| `live/` | The live decks of the part-day and full-day formats, whose slides carry the cells of the browser lab, with their segments |
| `slides/` | The decks of the third day of the multi-day format and their segments, with the two setup segments that every deck includes |
| `companion/` | The modules of the companion, written on the data of the case study; `_model-outputs/` holds the scripts and aggregate outputs behind them |
| `R/` | The pipeline that builds the data files of the case study; `R/README.md` gives the order |
| `data-raw/` | The archived inputs of the pipeline |
| `resources.qmd` | Readings, records, tools and the references of the site |
| `_variables.yml` | Site variables and the next-delivery block |

The downloadable workspace of the case study is the repository `CodeMoreh/ar4ds-housing-workspace`, and the browser lab and the live decks carry the same helper functions.

## Licence

Content is licensed [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/); the data of the case study are CC0.
