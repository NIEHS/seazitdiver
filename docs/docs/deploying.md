# Deploying

Deployment is orchestrated by the **deploy-seazit** repository, which contains
a set of [Fabric](http://www.fabfile.org/) tasks that rebuild and start the
individual Docker containers on the target server. Containers are orchestrated
via [docker-compose](https://docs.docker.com/compose/) and are configured to
restart automatically on failure.

The deploy-seazit repository is private (contains server hostnames, environment
variables, and nginx configuration). Access is limited to NTP maintainers.

Repository (internal access only): `NIEHS/deploy-seazit`

## Prerequisites

Before running deploy tasks locally:

- **Python 2.7 environment** with Fabric 1.14 (the legacy Fabric API is used):

    ```bash
    conda create -n py27 python=2.7
    conda activate py27
    conda install -c conda-forge fabric
    ```

- Read access to the `deploy-seazit` repository (holds `secrets.json` and
  per-environment `.env.*` templates).
- SSH access to the target server (staging, production, test, or vm_prod).
- A local checkout of `seazitdiver` at the path defined in `secrets.json`
  (`repo_dir`). Webpack builds run locally and are uploaded to the server as
  part of the Django rebuild.

## Deployment environments

Four environments are defined in `deploy-seazit/fabfile.py`:

| Environment  | Purpose                       | Compose file on server               |
|--------------|-------------------------------|--------------------------------------|
| `staging`    | Public staging site           | `docker-compose-staging.yml`         |
| `production` | Public production site        | `docker-compose-production.yml`      |
| `vm_prod`    | Alternate VM-based production | `docker-compose-production.yml`      |
| `test`       | Internal test server          | server-specific compose file         |

Each server has its own `.env.*` file containing database credentials,
`DJANGO_SECRET_KEY`, and other secrets. These live in
`deploy-seazit/templates/` and are copied to the target host by the
`copy_env` task.

## Common workflow

All commands are of the form `fab <environment> <module>.<task>`:

```bash
conda activate py27

# Rebuild the Django container on staging (most common workflow)
fab staging app.rebuild_django

# Rebuild the Django container in production
fab production app.rebuild_django

# Rebuild everything
fab production app.rebuild_all

# Rebuild only nginx (e.g. after changing nginx.conf)
fab production app.rebuild_nginx

# Update the checked-out branch on the server without rebuilding
fab production app.update_env
```

To list all available tasks:

```bash
fab --list
```

## Available task modules

Tasks are grouped by module inside `deploy-seazit/conf/`:

- **`app`** — main application tasks (most-commonly used):
  `rebuild_all`, `rebuild_django`, `rebuild_nginx`, `rebuild_redis`,
  `rebuild_rabbitmq`, `rebuild_postgres`, `update_env`, `restart_all`,
  `shell`, `db_shell`, `listDB`, `getDB`.
- **`provision`** — one-time server bootstrap: `setup` (Docker install,
  repo clone, initial build), `crons`, `copy_env`.
- **`server`** — server-level maintenance: `update_server`, `pass_nessus`.
- **`local`** — local build tasks: `shiny_bundle`.

## Notes and known quirks

- **Django `collectstatic`** runs automatically as the last step of
  `rebuild_django`. If static files fail to load after a deploy, rerun
  `collectstatic` manually inside the django container:

    ```bash
    docker compose -f docker-compose-production.yml exec django \
      /opt/conda/envs/seazit/bin/python /app/project/manage.py collectstatic --noinput
    ```

- **JavaScript is compiled locally**, not on the server. Make sure your local
  `seazitdiver` checkout is on the same branch and commit you intend to deploy.

- **Redis password** on `vm_prod` must be set manually the first time the
  redis container is created. See `deploy-seazit/readme.md` for the exact
  procedure.

- **HTTPS certificates** are copied into the nginx container as part of the
  provisioning step; refer to `deploy-seazit/readme.md` for regeneration.

For full details, refer to the `deploy-seazit` repository's `readme.md`.
