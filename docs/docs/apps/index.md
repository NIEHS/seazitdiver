# Applications overview

SEAZIT-DIVER runs as a set of Docker containers defined in the docker-compose files at the repository root (`docker-compose-staging.yml`, `docker-compose-production.yml`, `docker-compose-vm_prod.yml`).

A diagram describing the container layout is below:
![containers](../static/containers.png)

The main entrypoint is a Django web application (`project/seazit`) with a React frontend. nginx routes requests to Django; the Dataset and Quality control tabs embed R Shiny applications in iframes (see [Shiny applications](shiny.md)).

Supporting services:

- **PostgreSQL** - stores study data and the BMC analysis results (read through materialized views `mvw_seazit_*`)
- **Redis** - Django / REST API response cache (staging and production)
- **RServe** - optional R integration
