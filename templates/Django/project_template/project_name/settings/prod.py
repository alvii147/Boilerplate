import os

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = False

# frontend domain
SCHEME = 'https://'
DOMAIN = 'frontend.com'

# list of allowed server domains
ALLOWED_HOSTS = [
    'backend.com',
]

# list of client domains
CORS_ALLOWED_ORIGINS = [
    SCHEME + DOMAIN,
]

# email settings
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'smtp.gmail.com'
EMAIL_PORT = 587
EMAIL_HOST_USER = os.environ['{{ project_name|upper }}_EMAIL_HOST_USER']
EMAIL_HOST_PASSWORD = os.environ['{{ project_name|upper }}_EMAIL_HOST_PASSWORD']
EMAIL_USE_TLS = True
