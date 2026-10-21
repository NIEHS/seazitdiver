# Local, all-in-one image for SEAZIT (used by ./docker-compose-local.yml).
# Production images live in compose/django/Dockerfile and are NOT affected.

# ---------------------------------------------------------------------------
# Stage 1: build javascript bundles (replaces `npm run build` on a dev machine)
# ---------------------------------------------------------------------------
FROM node:22-bookworm-slim AS frontend

WORKDIR /build/project
RUN corepack enable && corepack prepare yarn@4.3.1 --activate

# install dependencies first (cached unless package.json / yarn.lock change)
COPY project/package.json project/yarn.lock project/.yarnrc.yml ./
RUN yarn install --immutable || yarn install

# build
COPY project/ ./
RUN NODE_ENV=production ./node_modules/.bin/webpack --config webpack.config.prod.js


# ---------------------------------------------------------------------------
# Stage 2: python runtime (same conda base + requirements as production)
# ---------------------------------------------------------------------------
FROM continuumio/miniconda3:24.11.1-0

RUN apt-get update && \
    apt-get install -y --no-install-recommends libpq-dev build-essential && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# python environment (cached unless conda.yml / requirements change)
COPY conda.yml /conda.yml
COPY requirements /requirements
RUN conda env create -f /conda.yml && \
    /opt/conda/envs/seazit/bin/python -m pip install --no-cache-dir --upgrade pip setuptools wheel && \
    /opt/conda/envs/seazit/bin/python -m pip install --no-cache-dir -r /requirements/docker.txt && \
    conda clean -afy

# same compat.py fix as the production image (six removed in Django 3+)
RUN sed -i \
    -e '/from django.utils import six/d' \
    -e 's/six\.PY2/False/g' \
    -e 's/six\.PY3/True/g' \
    -e 's/six\.binary_type/bytes/g' \
    -e 's/six\.string_types/str/g' \
    /opt/conda/envs/seazit/lib/python3.8/site-packages/rest_framework/compat.py

ENV PATH=/opt/conda/envs/seazit/bin:$PATH \
    PYTHONUNBUFFERED=1 \
    MPLCONFIGDIR=/tmp/matplotlib \
    DJANGO_SETTINGS_MODULE=main.settings.docker

# application code + compiled bundles from stage 1
COPY project /app/project
COPY --from=frontend /build/project/static_seazit/bundles /app/project/static_seazit/bundles
COPY --from=frontend /build/project/webpack-stats.json /app/project/webpack-stats.json
COPY compose/local/start.sh /start.sh

RUN groupadd -r django && useradd -r -g django django && \
    mkdir -p /app/public/static_seazit /app/public/media && \
    chmod +x /start.sh && \
    chown -R django:django /app

USER django
WORKDIR /app/project
EXPOSE 8000

CMD ["/start.sh"]
