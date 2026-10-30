# Build local Docker images

How to rebuild the two Docker images shipped in the SEAZIT tester package.
Audience: SEAZIT developers. Testers do not need to run these commands.

## What gets built

| Image | Built from | Purpose |
|---|---|---|
| `seazit-django:latest` | `compose/local/Dockerfile` | Django app (Node frontend + conda Python) |
| `postgres:17` | `compose/local/db.Dockerfile` | PostgreSQL 17 + curl |

Both are saved into a single file, `seazit-images_amd64.tar.gz`, that goes
into the tester package.

## Prerequisites

- Docker Desktop running.
- Repo checked out with these files on disk:
    - `compose/local/Dockerfile`
    - `compose/local/db.Dockerfile`
    - `compose/local/start.sh`
    - `requirements/docker.txt`
    - `project/main/settings/docker.py`
    - `.dockerignore` (recommended)
- ~5 GB free disk space.
- Internet access (for apt / pip / yarn during build).

## Build

Run from the repo root:

```bash
# 1. Django app image
docker build --platform linux/amd64 \
  -f compose/local/Dockerfile \
  -t seazit-django:latest .

# 2. Database image (PG17 + curl)
docker build --platform linux/amd64 \
  -f compose/local/db.Dockerfile \
  -t postgres:17 .

# 3. Save both images into a gzipped tarball
docker save --platform linux/amd64 \
  seazit-django:latest postgres:17 \
  | gzip > seazit-images_amd64.tar.gz
```

Expected tarball size: ~900 MB.

## Verify the tarball

```bash
ls -lh seazit-images_amd64.tar.gz
tar -xzOf seazit-images_amd64.tar.gz manifest.json
```

The manifest should list both `seazit-django:latest` and `postgres:17`.

## Ship to a tester package

Copy the tarball into the tester package folder (next to the tester's
`docker-compose.yml`), for example:

```
<tester-package>/seazit-local-package/seazit-images_amd64.tar.gz
```

## Smoke test

```bash
cd <tester-package>/seazit-local-package
docker load < seazit-images_amd64.tar.gz
docker compose up
```

Open [http://localhost:8000/seazit/app/](http://localhost:8000/seazit/app/)
in a browser. First boot restores `data.dump` and can take 15–20 minutes.
Subsequent starts are fast.

## Clean rebuild tips

- Force a fresh build:
  `docker rmi seazit-django:latest postgres:17`
- Remove dangling untagged images after `docker load`:
  `docker image prune`
- Keep `continuumio/miniconda3:24.11.1-0` cached to save ~10 min on
  future rebuilds.

## Why `--platform linux/amd64`?

Testers may be on Apple Silicon. Shipping amd64-only keeps the tarball
small and consistent. Docker Desktop on Apple Silicon runs the images
via emulation.
