import os

PROJECT_NAME = 'seazitdiver'
DB_NAME = 'dev_seazit'
PROJECT_PATH = os.path.abspath(os.path.join(os.path.dirname(__file__), '../..'))
PROJECT_ROOT = os.path.abspath(os.path.join(PROJECT_PATH, os.pardir))

DEBUG = True

ADMINS = []
_admin_names = os.getenv('DJANGO_ADMIN_NAMES', '')
_admin_emails = os.getenv('DJANGO_ADMIN_EMAILS', '')
if (len(_admin_names) > 0 and len(_admin_emails) > 0):
    ADMINS = list(zip(_admin_names.split('|'), _admin_emails.split('|')))

MANAGERS = ADMINS

SERVER_EMAIL = 'webmaster@sandbox.ntp.niehs.gov'

DATABASES = {
    'default': {
        # 'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'ENGINE': 'django.db.backends.postgresql',

        'NAME': DB_NAME,
        'OPTIONS': {
            'options': '-c search_path=schema_seazit'
        },
    },

}

DATABASE_ROUTERS = [
    # 'cebs.routers.CebsRouter',
]

TIME_ZONE = 'America/New_York'
LANGUAGE_CODE = 'en-us'

USE_I18N = True
USE_TZ = True

MEDIA_ROOT = os.path.join(PROJECT_ROOT, 'public', 'media')
MEDIA_URL = '/media/'

# STATIC_ROOT = os.path.join(PROJECT_ROOT, 'public', 'static')
# STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(PROJECT_ROOT, 'public', 'static_seazit')
STATIC_URL = '/static_seazit/'

STATICFILES_DIRS = (
    os.path.join(PROJECT_PATH, 'static_seazit'),
)

STATICFILES_FINDERS = (
    'django.contrib.staticfiles.finders.FileSystemFinder',
    'django.contrib.staticfiles.finders.AppDirectoriesFinder',
)

SECRET_KEY = 'a-wv-x8(e&z!3kry8zq2-apy(u8%6m7k2b80%h8wb57zmo&6v0'

MIDDLEWARE = (
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
)

ROOT_URLCONF = 'main.urls'
WSGI_APPLICATION = 'main.wsgi.application'

LOGIN_URL = 'login'
LOGIN_REDIRECT_URL = 'home'
LOGOUT_URL = 'logout'
LOGOUT_REDIRECT_URL = 'https://ntp.niehs.nih.gov/'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [
            os.path.join(PROJECT_PATH, 'templates'),
        ],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
                'django.template.context_processors.debug',
                'django.template.context_processors.media',
                'django.template.context_processors.request',
                'django.template.context_processors.i18n',
                'django.template.context_processors.static',
                'django.template.context_processors.tz',
                'main.context_processors.from_settings',
            ],
        },
    },
    {
        'NAME': 'jinja2',
        'BACKEND': 'django.template.backends.jinja2.Jinja2',
        'DIRS': [
            # os.path.join(PROJECT_PATH, 'fiveday', 'templates'),
        ],
        'APP_DIRS': True,
        'OPTIONS': {'environment': 'main.jinja.environment'},
    },
]

CRISPY_TEMPLATE_PACK = 'bootstrap3'
CRISPY_ALLOWED_TEMPLATE_PACKS = 'bootstrap3'

FIXTURE_DIRS = (
    os.path.join(PROJECT_PATH, 'fixtures'),
)

INSTALLED_APPS = (
    # Django apps
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'django.contrib.admin',
    'django.contrib.humanize',
    'django.contrib.sitemaps',
    # External apps
    'crispy_forms',
    'crispy_bootstrap3',
    'django_filters',
    'markdown_deux',
    'rest_framework',
    'rest_framework.authtoken',
    'webpack_loader',
    'corsheaders',
    'drf_yasg',
    'seazit',
    'utils',
)

# cache
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
        'LOCATION': '{}-cache'.format(PROJECT_NAME),
    }
}
TIMEOUT = 60 * 60  # cache for 1 hr

# email settings
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_SUBJECT_PREFIX = '[{}] '.format(PROJECT_NAME)
DEFAULT_FROM_EMAIL = 'webmaster@{}.com'.format(PROJECT_NAME)

# A sample logging configuration. The only tangible logging
# performed by this configuration is to send an email to
# the site admins on every HTTP 500 error when DEBUG=False.
# See http://docs.djangoproject.com/en/dev/topics/logging for
# more details on how to customize your logging configuration.
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'filters': {
        'require_debug_false': {
            '()': 'django.utils.log.RequireDebugFalse'
        }
    },
    'formatters': {
        'basic': {
            'format': '%(asctime)s %(name)-20s %(levelname)-8s %(message)s',
        },
    },
    'handlers': {
        'mail_admins': {
            'level': 'ERROR',
            'filters': ['require_debug_false'],
            'class': 'django.utils.log.AdminEmailHandler'
        },
        'console': {
            'level': 'INFO',
            'class': 'logging.StreamHandler',
            'formatter': 'basic',
        },
        'file': {
            'level': 'DEBUG',
            'class': 'logging.handlers.RotatingFileHandler',
            'formatter': 'basic',
            'filename': os.path.join(PROJECT_ROOT, '{}.log'.format(PROJECT_NAME)),
            'maxBytes': 10 * 1024 * 1024,  # 10 MB
            'backupCount': 10,
        },
        'null': {
            'class': 'logging.NullHandler',
        },
    },
    'loggers': {
        'django.security.DisallowedHost': {
            'handlers': ['null'],
            'propagate': False,
        },
        'django.request': {
            'handlers': ['mail_admins'],
            'level': 'ERROR',
            'propagate': True,
        },
        '': {
            'handlers': ['file', 'console'],
            'level': 'DEBUG',
        },
    }
}

REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework.authentication.SessionAuthentication',
        'rest_framework.authentication.TokenAuthentication',
    ),
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticatedOrReadOnly',
    ],
    'STRICT_JSON': False,
}

REST_FRAMEWORK_EXTENSIONS = {
    'DEFAULT_CACHE_RESPONSE_TIMEOUT': TIMEOUT,
    'DEFAULT_CACHE_KEY_FUNC': 'utils.api.calculate_cache_key',
}

SWAGGER_SETTINGS = {
    'SECURITY_DEFINITIONS': {
        'api_key': {
            'type': 'apiKey',
            'name': 'Authorization',
            'in': 'header',
            'description': 'Authorization token should be in format: "Token ${TOKEN}"',
        }
    }
}

# WEBPACK_LOADER = {
#     'DEFAULT': {
#         'BUNDLE_DIR_NAME': 'bundles/',
#         'STATS_FILE': os.path.join(PROJECT_PATH, 'webpack-stats.json'),
#         'POLL_INTERVAL': 0.1,
#         # 'IGNORE': ['.+/.map']
#         'IGNORES': ['.+/.map', r'.*\.map$', r'.*\.jpg$', r'.*\.png$', r'.*\.woff$', r'.*\.woff2$']
#
#     }
# }

WEBPACK_LOADER = {
    'DEFAULT': {
        'BUNDLE_DIR_NAME': 'bundles/',  # Directory where your bundles are stored
        'STATS_FILE': os.path.join(PROJECT_PATH, 'webpack-stats.json'),  # Path to the webpack-stats.json file
        'IGNORE': [r'.+\.hot-update.js', r'.+\.map','.+/.map']  # List of regex patterns to ignore
    }
}

MARKDOWN_DEUX_STYLES = {
    'default': {
        'extras': {
            'fenced-code-blocks': {},
            'header-ids': True,
            'tables': True,
        },
    },
}

CORS_ORIGIN_ALLOW_ALL = True
CORS_URLS_REGEX = r'/(tox21|seazit)/api/.*$'
