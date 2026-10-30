#!/bin/bash
# Start script for the local docker image (compose/local/Dockerfile).
set -e

echo "Waiting for Postgres at ${POSTGRES_HOST:-db}:${POSTGRES_PORT:-5432} ..."
until python - <<'END'
import os, sys, psycopg2
try:
    psycopg2.connect(
        dbname=os.environ.get('POSTGRES_DB', 'dev_seazit'),
        user=os.environ.get('POSTGRES_USER', 'seazit'),
        password=os.environ.get('POSTGRES_PASSWORD', 'seazit'),
        host=os.environ.get('POSTGRES_HOST', 'db'),
        port=os.environ.get('POSTGRES_PORT', '5432'),
    ).close()
except psycopg2.OperationalError:
    sys.exit(1)
END
do
  sleep 2
done
echo "Postgres is up."

python manage.py migrate --noinput
python manage.py collectstatic --noinput -v 0

echo "SEAZIT is running at http://localhost:${SEAZIT_PORT:-8000}"
exec gunicorn main.wsgi \
    --bind 0.0.0.0:8000 \
    --workers "${GUNICORN_WORKERS:-3}" \
    --timeout 120 \
    --access-logfile -
