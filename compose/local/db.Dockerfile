# Local database image (used by ./docker-compose-local.yml).
# Official PostgreSQL 16 (same major version as the source database) + curl,
# so local_data/00_restore.sh can download data.dump from the GitHub Release
# when it is not present in local_data/. Init scripts run as the "postgres"
# user, which cannot apt-get install at runtime - hence curl is baked in here.
FROM postgres:16

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*
