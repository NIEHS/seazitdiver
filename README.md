# SEAZIT-DIVER

**S**ystematic **E**valuation of the **A**pplication of **Z**ebrafish in **T**oxicology – **D**ata **I**ntegration and **V**isualization **E**nabling **R**esource

![Python](https://img.shields.io/badge/Python-3.8-blue?logo=python)
![Node](https://img.shields.io/badge/Node-22.5.1-green?logo=node.js)
![Yarn](https://img.shields.io/badge/Yarn-4.3.1-2C8EBB?logo=yarn)
![Django](https://img.shields.io/badge/Django-4.2.18-092E20?logo=django)
![License](https://img.shields.io/badge/License-CC0%201.0-lightgrey)

**Current version:** 2026-10-29 (see [CHANGELOG](CHANGELOG.md)) · **How to cite:** see [CITATION.cff](CITATION.cff)

---

## Overview

SEAZIT-DIVER is a web application for analyzing, comparing, and visualizing intra- and inter-laboratory zebrafish developmental toxicity data from the SEAZIT Interlaboratory Study, developed by the Division of Translational Toxicology (DTT) at NIEHS. Comparisons are organized on tabs:

| Tab | Content | Implementation |
|-----|---------|----------------|
| About | Study overview | React |
| Dataset | Experimental design, test substances, protocols, phenotype ontology | R Shiny (iframe) |
| Quality control | Plate- and assay-level QC | R Shiny (iframe) |
| Concentration response | Chemical-specific concentration-response curves | React + Django API |
| BMC by dataset | Benchmark concentration (BMC) ranking per lab/assay (Activity / Specificity) | React + Django API |
| Integrative analyses | Comparison across assays and laboratories | React + Django API |
| Resources | Publications and contributors | React |

The application combines a Django REST backend with a React/Webpack frontend, backed by a PostgreSQL database.

- **Public site:** https://seazit.dtt.niehs.nih.gov/

> **Scope of this repository.** This repository contains only SEAZIT-DIVER. Applications from the earlier NTP sandbox this codebase was derived from (tox21, neurotox, CEBS, fiveday, drugmatrix, IVIVE, job runner) have been removed.

---

## Tech Stack

| Layer          | Technology                           | Version  |
|----------------|--------------------------------------|----------|
| Language       | Python                               | 3.8      |
| Web framework  | Django                               | 4.2.18   |
| REST API       | Django REST Framework                | 3.14.0   |
| Frontend       | React                                | 16.x     |
| Bundler        | Webpack                              | 5.x      |
| Package mgr    | Yarn                                 | 4.3.1    |
| Runtime        | Node.js                              | 22.5.1   |
| Database       | PostgreSQL                           | —        |
| Data / Science | numpy, pandas, scipy, scikit-learn   | —        |
| Visualization  | matplotlib, plotly, seaborn          | —        |
| Docs           | MkDocs                               | 1.6.1    |
| R integration  | RServe                               | —        |

---

## Prerequisites

Install the following before setting up the project:

- [Anaconda or Miniconda](https://docs.conda.io/en/latest/miniconda.html)
- [Docker and Docker Compose](https://docs.docker.com/get-docker/)
- [Git](https://git-scm.com/)
- macOS only: `brew install freetype` (required for matplotlib)

---

## Installation

### 1. Clone the repository

```bash
cd ~/dev
git clone https://github.com/NIEHS/seazitdiver.git
cd seazitdiver
```

### 2. Create and activate the conda environment

```bash
conda env create -f conda.yml
conda activate seazit
```

This creates a conda environment named `seazit` with Python 3.8, Node 22.5.1, and Yarn 4.3.1.

### 3. Install Python dependencies

```bash
# macOS only
brew install freetype

pip install -r requirements/dev.txt
conda install pygraphviz
```

### 4. Configure local settings

```bash
cp ./project/main/settings/local.example.py ./project/main/settings/local.py
```

Edit `local.py` to configure your database connection and any environment-specific settings.

### 5. Install JavaScript dependencies

```bash
cd ./project
yarn install
```

---

## Database Setup

> **External users:** a public, schema-matched sample database and a self-contained Docker Compose setup are in progress (see [CHANGELOG](CHANGELOG.md) for status). Until then, the full SEAZIT dataset is hosted on an NIEHS-internal PostgreSQL server, and the steps below require NIEHS network (VPN) access.

### Connect to the NIEHS development database (VPN required)

Configure the connection in `project/main/settings/local.py` (copied from `local.example.py` in Installation step 4). Contact the SEAZIT-DIVER maintainers for credentials. Example:

```python
DATABASES['default'].update({
    'ENGINE': 'django.db.backends.postgresql_psycopg2',
    'NAME': 'dev_seazit',
    'OPTIONS': {'options': '-c search_path=schema_seazit'},
    'USER': '<db-user>',
    'PASSWORD': '<db-password>',
    'HOST': '<db-host>',
    'PORT': 5432,
})
```

Sync the database and create an admin user:

```bash
conda activate seazit
cd ~/dev/seazitdiver/project
python manage.py migrate
python manage.py createsuperuser
```

The SEAZIT data tables and materialized views (`mvw_seazit_*`) are not managed by Django migrations (`managed = False`); `migrate` only creates Django's own auth/admin tables.

---

## Running the Development Server

Two processes must run simultaneously: the Django application server and the Webpack dev server. Open two terminal windows.

**Terminal 1 — Django server:**

```bash
conda activate seazit
cd ~/dev/seazitdiver/project
python manage.py runserver 8000
```

> To make the server accessible on all network interfaces (e.g., on a remote server), use:
> `python manage.py runserver 0.0.0.0:8000`

**Terminal 2 — Webpack dev server:**

```bash
conda activate seazit
cd ~/dev/seazitdiver/project
npm start
```

Navigate to [http://127.0.0.1:8000/](http://127.0.0.1:8000/) to view the application.

**Optional — Start everything with tmux:**

```bash
cd ~/dev/seazitdiver
make dev
```

> **Note:** All conda environments must be fully deactivated before running `make dev`, otherwise conda environment switching within tmux will fail. See [conda issue #6796](https://github.com/conda/conda/issues/6796).

To customize the tmux layout:

```bash
cp ./bin/dev.sh ./bin/dev.local.sh
# Edit dev.local.sh as needed (remove lines 5-9 to prevent recursive segfault)
```

---

## Useful Make Commands

| Command          | Description                                    |
|------------------|------------------------------------------------|
| `make dev`       | Start full dev environment via tmux            |
| `make servedocs` | Start MkDocs documentation server (port 8002)  |
| `make dbdocs`    | Build auto-generated database documentation    |
| `make notebook`  | Start Jupyter notebook server                  |

---

## Documentation

Project documentation is built with [MkDocs](http://www.mkdocs.org/).

```bash
# Serve docs locally at http://localhost:8002
make servedocs
```

Diagrams are generated using [mermaid](https://github.com/mermaidjs/mermaid.cli). Use the [online editor](https://mermaidjs.github.io/mermaid-live-editor/) for quick iteration, or build from files:

```bash
cd docs
mmdc -t neutral -C ./diagrams/mmd.css \
    -i ./diagrams/containers.mmd \
    -o ./docs/static/containers.png
```

---

## Deployment

The NIEHS production deployment is managed through the private `NIEHS/deploy-seazit` repository, which contains Fabric tasks that rebuild and start the Docker containers on the NIEHS staging and production servers. See [`docs/docs/deploying.md`](docs/docs/deploying.md) for an overview.

---

## License and citation

SEAZIT-DIVER is released under [CC0 1.0 Universal](LICENSE) (public domain dedication). If you use SEAZIT-DIVER, please cite it using the metadata in [CITATION.cff](CITATION.cff).

---

## Troubleshooting / FAQ

### matplotlib error: "Python is not installed as a framework"

Add the following line to `~/.matplotlib/matplotlibrc` (create the file if it does not exist):

```
backend: TkAgg
```

### `selectable` package import error (`django.core.urlresolvers`)

The `django-selectable` package references a module path removed in modern Django. Fix it by editing the package source:

```bash
nano /opt/anaconda3/envs/seazit/lib/python3.8/site-packages/selectable/base.py
```

Change:

```python
from django.core.urlresolvers import reverse, NoReverseMatch
```

To:

```python
from django.urls import reverse, NoReverseMatch
```

### Reset the conda environment

If the environment becomes corrupted or you need a clean slate:

```bash
conda deactivate
conda remove --name seazit --all
conda env create -f conda.yml
```

### Verified working versions

| Tool  | Version |
|-------|---------|
| Yarn  | 4.3.1   |
| npm   | 10.8.2  |
| Node  | 22.5.1  |

To update npm globally:

```bash
npm update -g npm
```

### Simplify commands with conda environment variables

Create shell aliases that activate automatically with the conda environment. This example auto-navigates to the project directory when you activate the `seazit` env:

```bash
conda activate seazit
cd $CONDA_PREFIX
mkdir -p ./etc/conda/activate.d
mkdir -p ./etc/conda/deactivate.d
touch ./etc/conda/activate.d/env_vars.sh
touch ./etc/conda/deactivate.d/env_vars.sh
```

In `./etc/conda/activate.d/env_vars.sh`:

```bash
cd ~/dev/seazitdiver
```

In `./etc/conda/deactivate.d/env_vars.sh`:

```bash
cd ~
```
