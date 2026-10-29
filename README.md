# NTP SEAZIT-DIVER

**S**ystematic **E**valuation of the **A**pplication of **Z**ebrafish in **T**oxicology – **D**ata **I**ntegration and **V**isualization **E**nabling **R**esource

![Python](https://img.shields.io/badge/Python-3.8-blue?logo=python)
![Node](https://img.shields.io/badge/Node-22.5.1-green?logo=node.js)
![Yarn](https://img.shields.io/badge/Yarn-4.3.1-2C8EBB?logo=yarn)
![Django](https://img.shields.io/badge/Django-4.2.18-092E20?logo=django)
[![License](https://img.shields.io/badge/License-Public%20Domain-brightgreen)](LICENSE.md)
[![Latest Release](https://img.shields.io/github/v/release/NIEHS/seazitdiver)](https://github.com/NIEHS/seazitdiver/releases)

> An interactive web application for analyzing, comparing, and visualizing intra- and inter-laboratory zebrafish developmental toxicity data from the SEAZIT Interlaboratory Study.

---

## Overview

NTP SEAZIT is a Django-based web application developed for the National Toxicology Program (NTP) at NIEHS. It serves as a rapid prototyping and development platform for new data tooling ideas, supporting internal data analysis workflows, scientific visualizations, and tooling experiments across NTP research programs.

The application combines a Django REST backend with a React/Webpack frontend, backed by a PostgreSQL database. It is designed to be extensible — new apps and tools can be added quickly within the existing scaffold, making it a central hub for iterative NTP data tool development.

- **Production site:** https://seazit.dtt.niehs.nih.gov/
- **Staging site:** https://ehssv-falcon02.niehs.nih.gov/
- **Releases:** https://github.com/NIEHS/seazitdiver/releases (version history in [CHANGELOG.md](CHANGELOG.md))

---

## What you can do in SEAZIT-DIVER

- **Browse the SEAZIT Interlaboratory Study** — 41 test substances evaluated in concentration-response in triplicate by three laboratories under four assay conditions (intact chorion / dechorionated × static / static-renewal exposure).
- **Check data quality** at the plate and assay level.
- **View chemical-specific concentration-response curves** for mortality and altered phenotypes.
- **Rank test substances by benchmark concentration (BMC)** per laboratory and assay, by activity or by specificity (non-mortality vs. mortality effects).
- **Compare results across assays and laboratories** in integrative analyses.

Tabs: About · Dataset · Quality Control · Concentration Response · BMC by Dataset · Integrative Analyses · Resources.

---

## Developer setup

Installation, local development server, and troubleshooting: see [`docs/docs/dev_installation.md`](docs/docs/dev_installation.md).

---

## How to cite

If you use SEAZIT-DIVER, please cite the versioned release you used (see [Releases](https://github.com/NIEHS/seazitdiver/releases) and [CHANGELOG.md](CHANGELOG.md)); a software DOI is forthcoming.

Study data:

- Systematic Evaluation of the Application of Zebrafish in Toxicology (SEAZIT) Dose Range Finding (DRF) data. DOI: [10.22427/NTP-DATA-002-00102-0001-000-6](https://doi.org/10.22427/NTP-DATA-002-00102-0001-000-6)

Primary literature:

- Hamm, J., Hsieh, J.-H., Roberts, G., et al., Ryan, K.R., 2024. Interlaboratory Study on Zebrafish in Toxicology: Systematic Evaluation of the Application of Zebrafish in Toxicology's (SEAZIT's) Evaluation of Developmental Toxicity. *Toxics* 12, 93. [10.3390/toxics12010093](https://doi.org/10.3390/toxics12010093)
- Hsieh, J.-H., Nolte, S., Hamm, J.T., Wang, Z., Roberts, G.K., Schmitt, C.P., Ryan, K.R., 2023. Systematic Evaluation of the Application of Zebrafish in Toxicology (SEAZIT): Developing a Data Analysis Pipeline for the Assessment of Developmental Toxicity with an Interlaboratory Study. *Toxics* 11, 407. [10.3390/toxics11050407](https://doi.org/10.3390/toxics11050407)

---

## Questions and feedback

Please direct questions or suggestions to Kristen Ryan ([kristen.ryan@nih.gov](mailto:kristen.ryan@nih.gov)).
