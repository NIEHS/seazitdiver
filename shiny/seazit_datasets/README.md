# seazit_datasets — Datasets Shiny app

Source code for the **Datasets** tab of the SEAZIT web application
(Protocols / Test Substances / Phenotype Ontology, including a nested
"Data Density" sub-app). Migrated from the standalone `seazit-shiny` GitLab
repo, where it was previously deployed independently to Posit Connect.

- **Live URL:** https://rstudio.niehs.nih.gov/seazit_dataset/
- **Embedded via iframe in:** `project/seazit/templates/seazit/dataset.html`
- **Entry point:** `app.R`

## Running locally

This app must be run **with this directory as the working directory**
(it `source()`s files with relative paths like `./R/db_queries.R`,
`./global.R`). From RStudio, open `app.R` and click "Run App", or:

```r
shiny::runApp("shiny/seazit_datasets")
```

## Database configuration

1. Copy `config.yml.example` to `config.yml` in this directory.
2. Fill in the real `server`, `uid`, and `pwd` values (obtain from an NTP/NIEHS
   database administrator — these are **not** committed to this repository).
3. The app loads credentials via `config::get("seazit", file = "config.yml")`,
   reading the `default` profile unless `R_CONFIG_ACTIVE` is set (e.g. to
   `local_win` for the ODBC driver variant, used only for local Windows/RStudio
   development). Connections use `RPostgres::Postgres()` via a `pool::dbPool`
   against schema `schema_seazit`.

`config.yml` is gitignored — do not commit real credentials.

## Structure

- `app.R` — Shiny UI + server entry point; sources `global.R` and everything
  under `R/`, then sources the nested `endpoints-tab/` sub-app in place.
- `global.R` — small shared helpers (e.g. use-category color mapping).
- `R/db_queries.R` — Postgres queries (protocols, substances, ontology).
- `R/tb_change.R` — data wrangling / column adjustments for tables.
- `R/plot_funcs.R` — plotly chart construction (pie chart, Sankey diagram).
- `R/help_text.R` — static help text shown in collapsible info panels.
- `R/helpers.R` — small shared UI helpers.
- `data/*.xlsx`, `data/*.rds` — static reference data joined onto database
  results at startup (chemical property overrides, protocol parameter
  metadata, ontology mapping, Sankey background). If these files change
  shape, joins in `global.R`/`app.R` will silently produce `NA` columns
  rather than erroring — check them first when a table column looks wrong.
- `endpoints-tab/` — a self-contained mini Shiny app (own `app/ui2.R` +
  `app/server2.R`, `bin/plot_functions.R`, and prebuilt `data/seazit.rds`)
  that is `source()`-in-place from `app.R` rather than run as its own Shiny
  process. `server2.R`/`ui2.R` are the **current** "Data Density" tab in use;
  `server.R`/`ui.R` are an older "Number of Endpoints" tab, currently
  commented out in `app.R`'s UI. Check which pair is actually wired up in
  `app.R` before editing.
- `www/structure/*.png` — chemical structure images, one per DTXSID, served
  as static assets and referenced by `dtxsid` in the Test Substances table.
- `www/larva_image/`, `www/endpoints-tab/` — additional static assets
  (zebrafish larva diagram, Data Density tab CSS/JS).

## Related files in this repository

- `project/seazit/templates/seazit/dataset.html` — Django template that embeds the iframe
- `project/seazit/assets/seazit/containers/DatasetsMain.js` — React container for the Datasets tab
- `compose/shiny/` — Shiny server Docker configuration (deploy infrastructure)

## Future work

- Wire up credential injection for the Docker/`shiny-server` hosting model
  (currently only documented for local/RStudio use); this likely belongs
  alongside how the Django side's Postgres credentials are configured via the
  private `deploy-seazit` repository's `.env.*` files.
- Bundle and deploy via the `shiny_bundle` Fabric task in `deploy-seazit`.
