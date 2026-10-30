# Changelog

All notable changes to SEAZIT-DIVER are documented in this file. Versions are date-based (`YYYY-MM-DD`), newest first. Each release is tagged in git as `vYYYY-MM-DD`.

---

## [2026-10-29] — Current

### Fixed
- **BMC by dataset tab:** per-substance endpoint selection in `RankedBarchartHandler.js` used `_.min(iteratee)`, which in Lodash 4 ignores the iteratee and returns the first row. Replaced with `_.minBy`. Activity-mode non-mortality BMCs are unchanged (an upstream sort masked the bug); the Mortality BMC column (both modes) and Specificity-mode non-mortality BMCs now correctly show each substance's lowest BMC, and substances active on any selected endpoint are no longer shown as "-" in Specificity mode.

### Changed
- Rebranded docs, admin site, page templates, and specification from "NTP SEAZIT" to **SEAZIT-DIVER**.
- Removed legacy NTP sandbox material: docs pages for CEBS, neurotox, the 2017 workshop, and the GitLab-era contributing guide; legacy tox21 and neurotox schema images; `tox21` from `CORS_URLS_REGEX`; legacy nav entries from `docs/mkdocs.yml`.
- Trimmed `README.md` to the project overview. Developer setup (tech stack, installation, database connection, dev server, docs build, troubleshooting) moved to the private `deploy-seazit` repository (`docs/dev_setup.md`).
- Moved deployment documentation (`deploying.md`, `dbdocs.sh`) to the private `deploy-seazit` repository (`docs/`). `seazit_installation.md` was renamed `dev_installation.md`; it and `header_footer.md` remain in `docs/docs/` here, with copies also kept in `deploy-seazit/docs/` for maintainers.
- `Makefile` is no longer distributed (local developer convenience only; listed in `.gitignore`).
- Synced `spec.md` with the current repository: removed `Makefile` from the directory tree, replaced `make test` / `make test_all` with direct `pytest` commands, and updated the Database section to describe NIEHS-internal data access and the planned public sample database.
- Updated header/footer to the 2026-10 NTP shared header/footer (2026-10-14).
- nginx base image upgraded to `nginx:mainline-alpine`, libcurl bumped to 8.21.0, `server_tokens off` (2026-08-27).
- Renamed `SeazitApp` view/template/container to `Seazitdiver` (2026-08-26).
- Added `shiny/` placeholders for the Dataset and Quality control Shiny apps (2026-08-06).

### Added
- `LICENSE.md`: public domain / U.S. Government work notice.

---

## [2026-07-23]

- Redrafted `README.md` with comprehensive installation, database setup, dev server, testing, and troubleshooting documentation
- Added `spec.md` covering technical architecture, directory structure, backend/frontend stack, database configuration, auxiliary services (RServe), scientific libraries, and environment configuration
- Added `CHANGELOG.md` to track project version history going forward

---

## [2026-06-23]

- Project baseline at this date
- Django upgraded to 4.2.18; Django REST Framework 3.14.0 in place
- React 16 frontend bundled via Webpack 5 with `django-webpack-loader`
- Local development database via Docker PostgreSQL on port 5433
- Optional RServe container (port 6311) available for R-based analytics
- Conda environment `seazit` pinned to Python 3.8, Node 22.5.1, Yarn 4.3.1
- Core scientific stack in place: numpy 1.23.5, pandas 1.3.5, scipy 1.10.1, matplotlib 3.7.3, plotly 5.24.1, seaborn 0.13.2
