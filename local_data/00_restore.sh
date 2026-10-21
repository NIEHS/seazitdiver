#!/bin/bash
# Runs once, when the Postgres container starts with an EMPTY data volume
# (mounted at /docker-entrypoint-initdb.d by docker-compose-local.yml).
#
#  1. reads local_data/data.dump; if missing, downloads SEAZIT_DUMP_URL
#  2. verifies SEAZIT_DUMP_SHA256
#  3. creates public.median(numeric) (used by a materialized view; it lives
#     outside schema_seazit on the server, so older dumps do not contain it)
#  4. restores with --no-owner --no-privileges (server roles do not exist here)
#     and SKIPS the data of Django account tables (users, tokens, sessions...)
#
# Any error stops the container, so the app never starts on a half-loaded DB.
set -euo pipefail

DATA_DIR=/docker-entrypoint-initdb.d
WORK_DIR=/tmp/seazit_dump
mkdir -p "$WORK_DIR"

PSQL=(psql -v ON_ERROR_STOP=1 -q --username "$POSTGRES_USER" --dbname "$POSTGRES_DB")

# Django tables whose DATA is never restored (structure is still created).
# django_migrations and django_content_type are kept so `migrate` is a no-op.
SKIP_DATA_TABLES="auth_user auth_group auth_group_permissions auth_permission \
auth_user_groups auth_user_user_permissions authtoken_token django_admin_log django_session"

# ---------------------------------------------------------------- 1. pick dump
# Only this exact file is used; other *.dump files in local_data/ are ignored.
DUMP_NAME=data.dump
dump="$DATA_DIR/$DUMP_NAME"
downloaded=no

# printed when the automatic download is not possible (offline, proxy, firewall)
download_help() {
    local release_page="${SEAZIT_DUMP_URL%/download/*}"
    local tag="${SEAZIT_DUMP_URL#*/download/}"; tag="${tag%%/*}"
    echo "seazit: ------------------------------------------------------------------"
    echo "seazit: ERROR could not download $DUMP_NAME ($1)"
    echo "seazit:   from: $SEAZIT_DUMP_URL"
    echo "seazit: Fix: download it manually with a web browser from"
    echo "seazit:   $release_page/tag/$tag"
    echo "seazit: save it as local_data/$DUMP_NAME in the project folder, then run:"
    echo "seazit:   docker compose -f docker-compose-local.yml down -v"
    echo "seazit:   docker compose -f docker-compose-local.yml up -d"
    echo "seazit: ------------------------------------------------------------------"
}

if [ ! -f "$dump" ]; then
    if [ -z "${SEAZIT_DUMP_URL:-}" ]; then
        echo "seazit: no local_data/$DUMP_NAME and SEAZIT_DUMP_URL is empty - starting with an empty database"
        exit 0
    fi
    # local_data is mounted read-only, so the download goes to a temp folder
    dump="$WORK_DIR/$DUMP_NAME"
    downloaded=yes
    echo "seazit: local_data/$DUMP_NAME not found - downloading $SEAZIT_DUMP_URL"
    if ! command -v curl >/dev/null 2>&1; then
        # curl is installed by compose/local/db.Dockerfile; plain postgres images lack it
        download_help "curl is not installed in the db image - rebuild with: docker compose -f docker-compose-local.yml build db"
        exit 1
    fi
    if ! curl -fL --retry 3 --connect-timeout 30 --progress-bar -o "$dump" "$SEAZIT_DUMP_URL"; then
        download_help "network error, proxy/firewall, or file not published yet"
        exit 1
    fi
else
    echo "seazit: using local file $dump"
fi

# ------------------------------------------------------------- 2. verify sha256
if [ -n "${SEAZIT_DUMP_SHA256:-}" ]; then
    actual=$(sha256sum "$dump" | cut -d' ' -f1)
    if [ "$actual" = "$SEAZIT_DUMP_SHA256" ]; then
        echo "seazit: sha256 OK"
    elif [ "$downloaded" = yes ]; then
        echo "seazit: ERROR downloaded file sha256 mismatch (expected $SEAZIT_DUMP_SHA256, got $actual)"
        download_help "file is incomplete or corrupt"
        exit 1
    else
        echo "seazit: note - local dump differs from the published release (sha256 $actual); restoring it anyway"
    fi
fi

# ------------------------------------------------------------ 3. median()
echo "seazit: creating public.median(numeric)"
"${PSQL[@]}" <<'SQL'
CREATE OR REPLACE FUNCTION public._final_median(numeric[])
RETURNS numeric
LANGUAGE sql IMMUTABLE AS $$
    SELECT avg(val)
    FROM (
        SELECT val
        FROM unnest($1) val
        WHERE val IS NOT NULL
        ORDER BY 1
        LIMIT  2 - MOD(array_length(array_remove($1, NULL), 1), 2)
        OFFSET CEIL(array_length(array_remove($1, NULL), 1) / 2.0) - 1
    ) sub;
$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_aggregate a
        JOIN pg_proc p ON p.oid = a.aggfnoid
        JOIN pg_namespace n ON n.oid = p.pronamespace
        WHERE n.nspname = 'public' AND p.proname = 'median'
    ) THEN
        CREATE AGGREGATE public.median(numeric) (
            SFUNC = array_append,
            STYPE = numeric[],
            FINALFUNC = public._final_median,
            INITCOND = '{}'
        );
    END IF;
END $$;
SQL

# ---------------------------------------------------- 4. restore (filtered list)
list="$WORK_DIR/restore.list"
# TOC line format: "<id>; <oid> <oid> TABLE DATA <schema> <table> <owner>"
pg_restore --list "$dump" \
    | awk -v skip="$SKIP_DATA_TABLES" '
        BEGIN { n = split(skip, t, " "); for (i = 1; i <= n; i++) s[t[i]] = 1 }
        $4 == "TABLE" && $5 == "DATA" && ($7 in s) { next }
        ($4 == "AGGREGATE" || $4 == "FUNCTION") && $5 == "public" && $6 ~ /^(median|_final_median)\(/ { next }
        $4 == "SCHEMA" && $6 == "public" { next }
        $4 == "COMMENT" && $6 == "SCHEMA" && $7 == "public" { next }
        { print }' \
    > "$list"
skipped=$(pg_restore --list "$dump" | grep -c ' TABLE DATA ' || true)
kept=$(grep -c ' TABLE DATA ' "$list" || true)
echo "seazit: table data entries: $kept restored, $((skipped - kept)) skipped (account tables)"

echo "seazit: restoring (this can take several minutes) ..."
pg_restore \
    --username "$POSTGRES_USER" \
    --dbname "$POSTGRES_DB" \
    --no-owner --no-privileges \
    --exit-on-error \
    --jobs "$(nproc)" \
    --use-list "$list" \
    "$dump"

"${PSQL[@]}" -c "ALTER DATABASE \"$POSTGRES_DB\" SET search_path = schema_seazit, public;" -c "ANALYZE;"

rm -rf "$WORK_DIR"
echo "seazit: restore complete"
