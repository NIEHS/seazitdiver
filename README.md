# NTP SEAZIT-DIVER

**S**ystematic **E**valuation of the **A**pplication of **Z**ebrafish in **T**oxicology – **D**ata **I**ntegration and **V**isualization **E**nabling **R**esource

![Python](https://img.shields.io/badge/Python-3.8-blue?logo=python)
![Node](https://img.shields.io/badge/Node-22.5.1-green?logo=node.js)
![Yarn](https://img.shields.io/badge/Yarn-4.3.1-2C8EBB?logo=yarn)
![Django](https://img.shields.io/badge/Django-4.2.18-092E20?logo=django)
[![License](https://img.shields.io/badge/License-Public%20Domain-brightgreen)](LICENSE.md)

---

## Overview

NTP SEAZIT is a Django-based web application developed for the National Toxicology Program (NTP) at NIEHS. It serves as a rapid prototyping and development platform for new data tooling ideas, supporting internal data analysis workflows, scientific visualizations, and tooling experiments across NTP research programs.

The application combines a Django REST backend with a React/Webpack frontend, backed by a PostgreSQL database. It is designed to be extensible — new apps and tools can be added quickly within the existing scaffold, making it a central hub for iterative NTP data tool development.

- **Production site:** https://seazit.dtt.niehs.nih.gov/
- **Staging site:** https://ehssv-falcon02.niehs.nih.gov/
- **Deployment tooling:** `NIEHS/deploy-seazit` (private, maintainers only)
