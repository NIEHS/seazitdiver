# NTP SEAZIT — Technical Specification

**Version:** 2026-07-23
**Project:** NTP SEAZIT
**Organization:** National Toxicology Program (NTP), NIEHS

---

## 1. Overview

NTP SEAZIT is a full-stack Django web application designed as a rapid prototyping and data tooling platform for the National Toxicology Program at NIEHS. It provides a unified scaffold for building internal data analysis tools, REST APIs, scientific visualizations, and experimental features without requiring a new deployment environment for each project.

The application is intentionally structured to be extensible: new Django apps can be registered and new React-based frontend components integrated with minimal configuration. It serves both internal analysts and developers who need to build, test, and iterate on NTP data workflows quickly.

---

## 2. Architecture

### High-Level Flow

```
Browser
  │
  ▼
Django (port 8000)
  ├── Django REST Framework (API endpoints)
  ├── Django Templates (HTML shell pages)
  │     └── Loads React bundles via django-webpack-loader
  ├── PostgreSQL (port 5433, Docker in dev)
  └── RServe (port 6311, Docker in dev) ← optional R analytics
```

### Component Responsibilities

| Component             | Role                                                                 |
|-----------------------|----------------------------------------------------------------------|
| Django                | HTTP routing, business logic, ORM, admin, REST API, template rendering |
| Django REST Framework | JSON API endpoints consumed by React frontend                        |
| React + Redux         | Client-side UI; communicates with DRF API via fetch                  |
| Webpack               | Bundles React JS/CSS assets; emits `webpack-stats.json` for Django   |
| django-webpack-loader | Reads `webpack-stats.json`; injects correct bundle `<script>` tags   |
| PostgreSQL            | Persistent relational data store                                     |
| RServe                | Exposes R statistical computing to Django via TCP (port 6311)        |

### Dev vs. Production

- **Dev:** Webpack dev server runs separately (`npm start`); hot-reload enabled. Django reads bundles from `webpack-stats.json`.
- **Production:** `npm run build` produces static bundles in `static_seazit/bundles/`. Django serves them via whitenoise or a reverse proxy (see deploy repo).

---

## 3. Directory Structure

```
seazitdiver/
├── project/                    # Django project root
│   ├── manage.py
│   ├── main/                   # Core Django configuration
│   │   └── settings/           # Settings modules (base, local, production)
│   ├── seazit/                 # Primary Django application
│   ├── admin/                  # Admin customizations
│   ├── assets/                 # React JS source files (entry points, components)
│   ├── templates/              # Django HTML templates
│   ├── utils/                  # Shared Python utilities
│   ├── static_seazit/          # Compiled static assets (output of webpack build)
│   ├── webpack.base.js         # Shared Webpack config
│   ├── webpack.config.dev.js   # Dev Webpack config
│   ├── webpack.config.prod.js  # Production Webpack config
│   ├── webpack.devServer.js    # Webpack dev server entry
│   ├── package.json            # JS dependencies and npm scripts
│   └── setup.cfg               # pytest and flake8 configuration
├── requirements/
│   ├── seazit_base.txt         # Core Python dependencies
│   ├── dev.txt                 # Dev-only dependencies (includes base)
│   └── production.txt          # Production dependencies
├── compose/
│   ├── postgres/               # Dockerfile for PostgreSQL container
│   └── rserve/                 # Dockerfile for RServe container
├── docs/                       # MkDocs documentation source
├── bin/                        # Shell scripts (dev.sh, dev.local.sh)
├── conda.yml                   # Conda environment definition
├── Makefile                    # Developer convenience commands
├── docker-compose-production.yml   # Production stack
├── docker-compose-staging.yml      # Staging stack
├── docker-compose-vm_prod.yml      # VM production stack
└── .env                        # Local env vars (not committed; used by Docker)
```

---

## 4. Backend Stack

### Framework

| Package                  | Version   | Purpose                                              |
|--------------------------|-----------|------------------------------------------------------|
| Django                   | 4.2.18    | Web framework; ORM, routing, admin, templates        |
| djangorestframework      | 3.14.0    | REST API toolkit                                     |
| drf-yasg                 | 1.21.8    | Auto-generated Swagger/OpenAPI docs for DRF          |
| django-filter            | 24.3      | Queryset filtering for DRF viewsets                  |
| django-cors-headers      | 4.0.0     | Cross-Origin Resource Sharing headers                |
| drf-extensions           | 0.7.1     | DRF utilities (caching, mixins)                      |
| django-crispy-forms      | 2.3       | Bootstrap-styled Django form rendering               |
| crispy-bootstrap3        | ≥2024.1   | Bootstrap 3 template pack for crispy-forms           |
| django-extensions        | 3.2.3     | Shell plus, graph models, and other dev utilities    |
| django-webpack-loader    | ≥1.0,<2.0 | Injects Webpack-compiled bundles into Django templates|
| django-markdown-deux     | 1.0.6     | Markdown rendering in Django views/templates         |
| psycopg2-binary          | —         | PostgreSQL adapter for Python                        |

### Settings Pattern

Settings are split into three modules under `project/main/settings/`:

| File               | Purpose                                              |
|--------------------|------------------------------------------------------|
| `base.py`          | Shared settings (installed apps, middleware, etc.)   |
| `local.py`         | Developer-specific overrides (DB credentials, DEBUG) |
| `local.example.py` | Template for `local.py`; committed to version control|
| `production.py`    | Production overrides (security headers, static files)|

The active settings module is selected via the `DJANGO_SETTINGS_MODULE` environment variable.

---

## 5. Frontend Stack

### Core Libraries

| Package             | Version | Purpose                                           |
|---------------------|---------|---------------------------------------------------|
| react               | 16.x    | UI component library                              |
| react-dom           | 16.x    | DOM rendering                                     |
| redux               | 3.x     | Application state management                      |
| react-redux         | 5.x     | React bindings for Redux                          |
| @material-ui/core   | 4.x     | UI component library (Material Design)            |
| d3                  | 4.x     | Data-driven SVG visualizations                    |
| papaparse           | 5.x     | CSV parsing                                       |
| xlsx                | 0.11.x  | Excel file parsing and generation                 |
| lodash              | 4.x     | Utility functions                                 |
| isomorphic-fetch    | 2.x     | Fetch API polyfill for API calls                  |

### Build Tooling

| Package                  | Version | Purpose                                           |
|--------------------------|---------|---------------------------------------------------|
| webpack                  | 5.x     | Module bundler                                    |
| webpack-bundle-tracker   | 2.x     | Emits `webpack-stats.json` consumed by Django     |
| webpack-dashboard        | 3.x     | Terminal UI for webpack dev server                |
| babel-loader             | 9.x     | Transpiles modern JS/JSX via Babel                |
| @babel/preset-env        | 7.x     | Transpile modern JS to ES5                        |
| @babel/preset-react      | 7.x     | Transpile JSX                                     |
| css-loader               | 6.x     | Processes CSS imports in JS                       |
| mini-css-extract-plugin  | 2.x     | Extracts CSS into separate files (production)     |
| eslint                   | 4.x     | JavaScript linter                                 |
| prettier                 | 1.x     | Code formatter (JS, CSS, JSON)                    |
| husky + lint-staged      | —       | Pre-commit hooks for linting and formatting       |

### Entry Points and Webpack Configs

| File                      | Purpose                                              |
|---------------------------|------------------------------------------------------|
| `webpack.base.js`         | Shared loaders and aliases                           |
| `webpack.config.dev.js`   | Dev build (source maps, fast rebuild)                |
| `webpack.config.prod.js`  | Production build (minification, content hashing)     |
| `webpack.devServer.js`    | Dev server with hot module replacement               |

---

## 6. Database

### Configuration

Local development connects to the shared NTP PostgreSQL development server over NIEHS VPN. Production and staging deployments connect via Docker to the same or related PostgreSQL instances defined in the deployment repository's `.env.*` files.

| Property    | Value                                                            |
|-------------|------------------------------------------------------------------|
| Engine      | PostgreSQL                                                       |
| Schema      | `schema_seazit`                                                  |
| Database    | `dev_seazit` (dev), `seazit` (production)                        |
| Auth        | Configured in `project/main/settings/local.py` (dev) or via env vars in production `.env.*` files |

Environment variables consumed by non-dev settings modules:

| Variable                | Purpose                    |
|-------------------------|----------------------------|
| `POSTGRES_SERVER_IP`    | Database host              |
| `POSTGRES_DBNAME`       | Database name              |
| `POSTGRES_USER`         | Database user              |
| `POSTGRES_PASSWORD`     | Database password          |
| `PORT`                  | Database port              |

---

## 7. Auxiliary Services

### RServe

RServe provides a TCP server interface to the R statistical computing environment, enabling Django to invoke R functions and retrieve results programmatically. Deployed as a Docker container in production/staging.

| Property | Value                              |
|----------|------------------------------------|
| Port     | 6311                               |
| Docker   | `compose/rserve/` Dockerfile       |
| Usage    | Required only by apps that invoke R analytics |

---

## 8. Scientific / Data Libraries

| Library       | Version   | Purpose                                                  |
|---------------|-----------|----------------------------------------------------------|
| numpy         | 1.23.5    | Numerical arrays and math operations                     |
| pandas        | 1.3.5     | Tabular data manipulation (DataFrames)                   |
| scipy         | 1.10.1    | Scientific computing (statistics, signal processing)     |
| scikit-learn  | ≥0.22     | Machine learning algorithms                              |
| matplotlib    | 3.7.3     | Static 2D plotting and figure generation                 |
| seaborn       | 0.13.2    | Statistical data visualization (built on matplotlib)     |
| plotly        | 5.24.1    | Interactive web-based charts                             |
| jupyter       | 1.1.1     | Notebook environment for exploratory analysis            |
| openpyxl      | 3.1.5     | Read/write Excel (.xlsx) files                           |
| xlrd          | 2.0.1     | Read legacy Excel (.xls) files                           |
| docxtpl       | 0.19.0    | Template-based Word (.docx) document generation          |

---

## 9. Configuration and Environments

### Environment Files

| File                                | Purpose                                              |
|-------------------------------------|------------------------------------------------------|
| `conda.yml`                         | Conda environment (Python, Node, Yarn pins)          |
| `.env`                              | Docker secrets (DB credentials); not committed       |
| `project/main/settings/local.py`    | Django local overrides; not committed                |
| `project/main/settings/local.example.py` | Template for `local.py`                         |

### Docker Compose Targets

| File                              | Environment          |
|-----------------------------------|----------------------|
| `docker-compose-staging.yml`      | Staging server       |
| `docker-compose-production.yml`   | Production           |
| `docker-compose-vm_prod.yml`      | VM-based production  |

### Pytest Configuration

Configured in `project/setup.cfg`. Run via:

```bash
make test         # unit tests only
make test_all     # unit + integration (PYTEST_INTEGRATION=T)
```

### Linting and Formatting

- **ESLint:** Configured via `.eslintrc` (or inline in `package.json`). Plugins: `eslint-plugin-react`, `eslint-plugin-babel`.
- **Prettier:** Configured via `project/.prettierrc`. Runs on `.js`, `.css`, `.json` files.
- **Pre-commit hook:** `husky` + `lint-staged` run Prettier automatically on staged files before each commit.
