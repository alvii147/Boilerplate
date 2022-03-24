# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

# frontend domain
SCHEME = 'http://'
DOMAIN = 'localhost:3000'

# list of allowed server domains
ALLOWED_HOSTS = []

# list of client domains
CORS_ALLOWED_ORIGINS = [
    SCHEME + DOMAIN,
]

# email settings
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
