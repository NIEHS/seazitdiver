# Manual DB connectivity check; uses the same environment variables as entrypoint.sh.
import os
import sys

import psycopg2

try:
    conn = psycopg2.connect(
        user=os.environ['POSTGRES_USER'],
        password=os.environ['POSTGRES_PASSWORD'],
        host=os.environ['POSTGRES_SERVER_IP'],
        port=os.environ.get('PORT', '5432'),
        dbname=os.environ['POSTGRES_DBNAME'],
    )
    cur = conn.cursor()
    print('PostgreSQL database version:')
    cur.execute('SELECT version()')
    print(cur.fetchone())
    conn.close()
except psycopg2.OperationalError:
    sys.exit(-1)
sys.exit(0)
