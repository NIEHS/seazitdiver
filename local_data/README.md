# SEAZIT local database

On the **first** `docker compose -f docker-compose-local.yml up` (empty database volume) the `db` container runs
[`00_restore.sh`](00_restore.sh), which:

1. reads **`local_data/data.dump`** (only this exact file name is used), or, if it is missing,
2. downloads `data.dump` from the GitHub Release set in `SEAZIT_DUMP_URL` (see `docker-compose-local.yml`),
3. verifies `SEAZIT_DUMP_SHA256`,
4. creates `public.median(numeric)` (used by materialized view `mvw_seazit_bmc_min_max`),
5. restores with `pg_restore --no-owner --no-privileges`, **skipping the data** of Django account
   tables (`auth_*`, `authtoken_token`, `django_admin_log`, `django_session`).

Restored database is ~3.2 GB; the restore takes under a minute on a recent laptop.
Any error stops the `db` container (`docker compose -f docker-compose-local.yml logs db`), so the app
never runs on a partial database.

Dump files (`*.dump`) are **not** stored in git (GitHub limit is 100 MB); they are published as
GitHub Release assets.

## Current dump

| | |
|---|---|
| File | `data.dump` (106 MB, pg_dump custom format) |
| Release | tag `data-2026-10-20`, asset `data.dump` |
| SHA-256 | `1706cb548ea8cf7293a343a99be588f1115bf19618b7802d72fffdaf65a73859` |
| Source | `dev_seazit`, schema `schema_seazit`, PostgreSQL 16.2, 2026-10-20 |
| Contents | 74 data tables + 8 materialized views + `public.median`; account tables are empty |

## Reload the database

```bash
docker compose -f docker-compose-local.yml down -v      # -v deletes the local database volume
docker compose -f docker-compose-local.yml up -d
```

No image rebuild is needed when only `data.dump` or `00_restore.sh` changes.

Create an admin login for `/batcave/` (no users are included in the dump):

```bash
docker compose -f docker-compose-local.yml exec django python manage.py createsuperuser
```

## Publish a new dump (maintainers)

1. Dump from the server (VPN required, read-only on the server). Keep this raw file
   **outside** the repo - it contains user accounts/sessions and must **never be published**:

   ```bash
   pg_dump -h ehsdtt031535.niehs.nih.gov -U <db-user> -d dev_seazit \
     -n schema_seazit -Fc -f ~/seazit_<date>_raw.dump
   ```

2. Make the public dump (restores the raw dump into a throw-away container with this folder's
   `00_restore.sh`, which drops account data, then dumps again):

   ```bash
   mkdir -p /tmp/seazit_in
   cp local_data/00_restore.sh /tmp/seazit_in/
   cp ~/seazit_<date>_raw.dump /tmp/seazit_in/data.dump      # script only reads data.dump
   docker run -d --name seazit-dumpbuild -e POSTGRES_DB=dev_seazit -e POSTGRES_USER=seazit \
     -e POSTGRES_PASSWORD=seazit -v /tmp/seazit_in:/docker-entrypoint-initdb.d:ro postgres:16
   docker logs -f seazit-dumpbuild          # wait for "seazit: restore complete", then Ctrl-C
   docker exec seazit-dumpbuild pg_dump -U seazit -d dev_seazit -Fc -Z 9 \
     -n schema_seazit -n public --no-owner --no-privileges -f /tmp/data.dump
   docker cp seazit-dumpbuild:/tmp/data.dump local_data/data.dump
   docker rm -f seazit-dumpbuild && rm -rf /tmp/seazit_in
   shasum -a 256 local_data/data.dump
   ```

3. On GitHub: **Releases → Draft a new release**, tag `data-<date>`, attach `local_data/data.dump`, publish.
4. Update `SEAZIT_DUMP_URL` (tag part) / `SEAZIT_DUMP_SHA256` in `docker-compose-local.yml` and the table above.
