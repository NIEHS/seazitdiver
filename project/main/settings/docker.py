"""
Settings for running SEAZIT locally with
`docker compose -f docker-compose-local.yml up`.

- Database: local Postgres container (see docker-compose-local.yml), restored from local_data/data.dump
- Cache: in-memory (no Redis)
- Static files: served by Django via whitenoise (no nginx)
"""
import os

from main.settings.base import *  # noqa

DEBUG = os.environ.get('DJANGO_DEBUG', 'False') == 'True'

SECRET_KEY = os.environ.get(
    'DJANGO_SECRET_KEY',
    'local-docker-only-not-secret-change-me',
)

ALLOWED_HOSTS = os.environ.get('ALLOWED_HOSTS', 'localhost|127.0.0.1|0.0.0.0').split('|')
CSRF_TRUSTED_ORIGINS = [
    'http://localhost:8000',
    'http://127.0.0.1:8000',
]

DATABASES['default'].update({
    'NAME': os.environ.get('POSTGRES_DB', 'dev_seazit'),
    'USER': os.environ.get('POSTGRES_USER', 'seazit'),
    'PASSWORD': os.environ.get('POSTGRES_PASSWORD', 'seazit'),
    'HOST': os.environ.get('POSTGRES_HOST', 'db'),
    'PORT': os.environ.get('POSTGRES_PORT', '5432'),
    'OPTIONS': {
        # app tables live in schema_seazit (same as the servers); public is a
        # fallback so migrate still works before the dump is loaded
        'options': '-c search_path=schema_seazit,public',
    },
})

# serve collected static files from gunicorn
MIDDLEWARE = (
    MIDDLEWARE[:1]
    + ('whitenoise.middleware.WhiteNoiseMiddleware',)
    + MIDDLEWARE[1:]
)
STATIC_ROOT = '/app/public/static_seazit'
MEDIA_ROOT = '/app/public/media'

EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

# log to console only (docker compose -f docker-compose-local.yml logs django)
LOGGING['handlers'].pop('file', None)
LOGGING['loggers']['']['handlers'] = ['console']
LOGGING['loggers']['']['level'] = 'INFO'

ENVIRONMENT_NAME = 'Local Docker'
ENVIRONMENT_COLOR = '#2E7D32'
