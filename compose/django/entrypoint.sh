#!/bin/bash

set -e
cmd="$@"

# the official postgres image uses 'postgres' as default user if not set explictly.
if [ -z "$POSTGRES_USER" ]; then
    export POSTGRES_USER=postgres
fi
#This for postgres docker
#export DATABASE_URL=postgres://$POSTGRES_USER:$POSTGRES_PASSWORD@postgres:5437/$POSTGRES_USER
#export POSTGRES_PASSWORD=my_dev_password
#This is for db server
export DATABASE_URL=postgres://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_SERVER_IP:$PORT/$POSTGRES_USER
 
function postgres_ready(){
/opt/conda/envs/seazit/bin/python << 'END'
import os
import sys
import psycopg2

try:
    # connection values come from the server .env file
    # (deploy-seazit/templates/.env.<env>), same values Django uses
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
END
}


# ensure we can connect to redis client;
# requires REDIS_CONNECTION_STRING environment variable
function redis_ready(){
/opt/conda/envs/seazit/bin/python << END
import sys
import redis
try:
    client = redis.StrictRedis.from_url("$REDIS_CONNECTION_STRING")
    client.ping()
except redis.exceptions.ConnectionError:
    sys.exit(-1)
sys.exit(0)
END
}

function python_ready(){
/opt/conda/envs/seazit/bin/python << END
import sys
import markdown
try: 
    print(markdown)
    if markdown.__version__ <= '2.2':
        print('makedow version property updated __version__')
except:
    sys.exit(-1)
sys.exit(0)
END
    
}

until postgres_ready; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

# only wait for redis when it is configured (servers set it in .env)
if [ -n "$REDIS_CONNECTION_STRING" ]; then
  until redis_ready; do
    >&2 echo "Redis is unavailable - sleeping"
    sleep 1
  done
fi

until python_ready; do
  >&2 echo "python_ready is unavailable - sleeping"
  sleep 1
done

>&2 echo "Postgres and Redis are up - continuing..."
exec $cmd
