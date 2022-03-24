import os

try:
    DJANGO_ENV = os.environ['{{ project_name|upper }}_DJANGO_ENV']
except KeyError:
    raise EnvironmentError(
        'Invalid environment set. '
        'Please set {{ project_name|upper }}_DJANGO_ENV environment variable to '
        '"development" or "production"'
    )

if DJANGO_ENV.lower() == 'development':
    from .dev import *
elif DJANGO_ENV.lower() == 'production':
    from .prod import *
else:
    raise EnvironmentError(
        'Invalid environment set. '
        'Please set {{ project_name|upper }}_DJANGO_ENV environment variable to '
        '"development" or "production"'
    )

from .base import *
