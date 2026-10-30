# SEAZIT-DIVER

**S**ystematic **E**valuation of the **A**pplication of **Z**ebrafish in **T**oxicology – **D**ata **I**ntegration and **V**isualization **E**nabling **R**esource

![Python](https://img.shields.io/badge/Python-3.8-blue?logo=python)
![Node](https://img.shields.io/badge/Node-22.5.1-green?logo=node.js)
![Yarn](https://img.shields.io/badge/Yarn-4.3.1-2C8EBB?logo=yarn)
![Django](https://img.shields.io/badge/Django-4.2.18-092E20?logo=django)
[![License](https://img.shields.io/badge/License-Public%20Domain-brightgreen)](LICENSE.md)
[![Latest Release](https://img.shields.io/github/v/release/NIEHS/seazitdiver)](https://github.com/NIEHS/seazitdiver/releases)

> An interactive web application for exploring and comparing zebrafish embryonic developmental toxicity data from the SEAZIT Interlaboratory Study.

## Overview

SEAZIT-DIVER provides interactive access to 15 zebrafish developmental toxicity datasets from three laboratories, covering dose-range-finding (DRF) and definitive study phases. The study includes 42 blinded test substances representing 39 unique substances and three duplicates, with definitive-phase testing across four combinations of chorion status and exposure-media renewal. The application links protocols, phenotype ontology mappings, quality-control summaries, and precomputed benchmark concentration (BMC) and phenotype-specificity results to underlying concentration–response data, supporting exploration across substances, laboratories, and exposure conditions while accounting for differences in endpoint coverage.

- **Public application:** [SEAZIT-DIVER](https://seazit.dtt.niehs.nih.gov/seazit/) — accessible through a web browser without local installation.
- **Staging site:** [Internal staging environment](https://ehssv-falcon02.niehs.nih.gov/) — accessible only to internal users.
- **Software releases:** [Versioned releases](https://github.com/NIEHS/seazitdiver/releases), including a Docker deployment package and a separate database snapshot. See [CHANGELOG.md](CHANGELOG.md) for version history.

## Explore the Data

- **Datasets:** Compare protocols, test-substance information, phenotype mappings, and endpoint coverage.
- **Quality Check:** Review vehicle controls, positive controls, and blinded-duplicate reproducibility.
- **Concentration-Response:** Inspect and compare plate-level response curves.
- **BMC by Dataset:** Rank substances by potency or phenotype specificity and inspect supporting curves.
- **Integrative Analyses:** Compare developmental defect classifications, potency, and specificity across datasets.
- **Resources:** Access publications and bulk data.

## Developer Setup

The application uses a Django and Django REST framework backend, a PostgreSQL database, and interactive visualizations built with React, D3.js, Plotly.js, and R/Shiny.

For installation, local development, and troubleshooting, see the [developer installation guide](docs/docs/dev_installation.md). Additional technical documentation is available in [spec.md](spec.md) and [docs/](docs/).

## Citation and Related Publications

When using SEAZIT-DIVER, cite the software version used (see [Releases](https://github.com/NIEHS/seazitdiver/releases) and [CHANGELOG.md](CHANGELOG.md)) and the relevant manuscript or study publications below.

### SEAZIT-DIVER Manuscript

Hsieh, J.-H., Wang, Z., Nolte, S., Marvel, S. W., Hill, B. N., Hamm, J. T., Roberts, G. K., and Ryan, K. R. *SEAZIT-DIVER: A Web Application for Integrating and Visualizing Interlaboratory Zebrafish Embryonic Developmental Toxicity Data.* Manuscript in revision.

### Study Publications

- Hamm, J. T., Hsieh, J.-H., Roberts, G. K., et al. (2024). Interlaboratory Study on Zebrafish in Toxicology: Systematic Evaluation of the Application of Zebrafish in Toxicology's (SEAZIT's) Evaluation of Developmental Toxicity. *Toxics*, 12, 93. [doi:10.3390/toxics12010093](https://doi.org/10.3390/toxics12010093)
- Hsieh, J.-H., Nolte, S., Hamm, J. T., Wang, Z., Roberts, G. K., Schmitt, C. P., and Ryan, K. R. (2023). Systematic Evaluation of the Application of Zebrafish in Toxicology (SEAZIT): Developing a Data Analysis Pipeline for the Assessment of Developmental Toxicity with an Interlaboratory Study. *Toxics*, 11, 407. [doi:10.3390/toxics11050407](https://doi.org/10.3390/toxics11050407)

### Study Data

Systematic Evaluation of the Application of Zebrafish in Toxicology (SEAZIT) Dose Range Finding (DRF) data. [doi:10.22427/NTP-DATA-002-00102-0001-000-6](https://doi.org/10.22427/NTP-DATA-002-00102-0001-000-6)

## Questions and Feedback

Please direct questions or suggestions to Kristen Ryan ([kristen.ryan@nih.gov](mailto:kristen.ryan@nih.gov)).
