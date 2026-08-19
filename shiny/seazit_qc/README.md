# seazit_qc — Quality Control Shiny app

Source code for the **Quality Check** tab of the SEAZIT web application
(Vehicle Control / Positive Control / Duplicates). Migrated from the
standalone `seazit-shiny` GitLab repo, where it was previously deployed
independently to Posit Connect.

- **Live URL:** https://rstudio.niehs.nih.gov/seazit_qc/
- **Embedded via iframe in:** `project/seazit/templates/seazit/qc.html`
- **Entry point:** `app.R`

## Running locally

This app must be run **with this directory as the working directory**
(it `source()`s files with relative paths like `./R/db_queries.R`). From
RStudio, open `app.R` and click "Run App", or:

```r
shiny::runApp("shiny/seazit_qc")
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

- `app.R` — Shiny UI + server entry point; sources everything under `R/`.
- `global.R` — defines `api_base`, a URL for the (currently unused) `seazit_api`
  Plumber API. Not sourced by `app.R`; the app queries Postgres directly.
- `R/db_queries.R` — Postgres queries (protocols, substances, incidence, BMC).
- `R/tb_change.R` — data wrangling / column adjustments for tables and plots.
- `R/plot_funcs.R` — plotly chart construction.
- `R/select_module.R` — a small Shiny module (`selectInputColumnUI`/
  `selectInputColumnServer`) implementing cascading filter dropdowns, reused
  across the VC/PC/Duplicates tabs.
- `R/help_text.R` — static help text shown in collapsible info panels.
- `R/helpers.R` — small shared UI helpers (e.g. tooltip wrapper).

## Related files in this repository

- `project/seazit/templates/seazit/qc.html` — Django template that embeds the iframe
- `project/seazit/assets/seazit/containers/QualityControlMain.js` — React container for the QC tab
- `compose/shiny/` — Shiny server Docker configuration (deploy infrastructure)

## Future work

- Wire up credential injection for the Docker/`shiny-server` hosting model
  (currently only documented for local/RStudio use); this likely belongs
  alongside how the Django side's Postgres credentials are configured via the
  private `deploy-seazit` repository's `.env.*` files.
- Bundle and deploy via the `shiny_bundle` Fabric task in `deploy-seazit`.
