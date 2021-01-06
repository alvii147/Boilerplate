# ----------------------------------------------------------------------
# Flask Boilerplate Script
# ----------------------------------------------------------------------
# Options:
# -a = app name
# -d, setup SQLite3 database
# ----------------------------------------------------------------------
# Requirements:
# - Flask
# - Flask SQLAlchemy
# ----------------------------------------------------------------------

flask_boilerplate() {
    # Check for flask and flasksqlalchemy installation
    flask_install=`$PYTHON_CMD -c "import flask" 2>&1`
    flask_sqlalchemy_install=`$PYTHON_CMD -c "import flask_sqlalchemy" 2>&1`
    if [ ! -z "$flask_install" ]; then
        echo -e "\nWARNING: Flask is not installed"
        echo -e "Please install Flask"
        echo -e "Run \"pip install flask\""
    fi
    if [ ! -z "$flask_sqlalchemy_install" ]; then
        echo -e "\nWARNING: Flask SQLAlchemy is not installed"
        echo -e "Please install Flask SQLAlchemy"
        echo -e "Run \"pip install flask-sqlalchemy\""
    fi

    # Random string for secret key
    secret_key=`openssl rand -base64 12`

    # Import SQLAlchemy
    IFS= read -r -d '' import_sqlalchemy <<EOS
from flask_sqlalchemy import SQLAlchemy
EOS

    # SQLite3 database configurations
    IFS= read -r -d '' db_config <<EOS
app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///users.sqlite3"
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
db = SQLAlchemy(app)
EOS

    # User model for database
    IFS= read -r -d '' user_model <<EOS
class User(db.Model):
    id = db.Column("id", db.Integer, primary_key=True)
    name = db.Column(db.String(150))

    def __init__(self, name):
        self.name = name
EOS

    # Create database
    IFS= read -r -d '' db_create_all <<EOS
    db.create_all()
EOS

    if [ -z $SETUP_DATABASE ]; then
        unset import_sqlalchemy db_config user_model db_create_all
    fi

    # Write to app.py
    cat > $APP_NAME.py <<EOF
from flask import Flask, render_template
${import_sqlalchemy}
app = Flask(__name__)
app.secret_key = "${secret_key}"${db_config}
${user_model}
@app.route("/")
def home():
    return render_template("home.html")

if __name__ == "__main__":
${db_create_all}    app.run(debug=True)
EOF

    # HTML templates
    mkdir -p templates
    cd templates
    cat > home.html <<EOF
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel = "stylesheet" type = "text/css" href = "{{url_for('static', filename = 'styles.css')}}">
        <title>My Flask App</title>
    </head>
    <body>
        <div class="centerdiv">
            <h1 class="centerh1">Welcome to your Flask app!</h1>
            <img class="centerimg" src="https://flask.palletsprojects.com/en/1.1.x/_images/flask-logo.png" alt="Flask logo">
        </div>
    </body>
</html>
EOF

    # Style sheets
    cd ..
    mkdir -p static
    cd static
    cat > styles.css <<EOF
.centerdiv {
  margin: auto;
  width: 50%;
  border: 3px solid black;
  border-radius: 5px;
  padding: 10px;
}
.centerh1 {
  margin: auto;
  width: 50%;
  padding: 10px;
  font-family: Georgia;
}
.centerimg {
  display: block;
  margin-left: auto;
  margin-right: auto;
  width: 50%;
}
EOF
}

# ----------------------------------------------------------------------
# Django Boilerplate Script
# ----------------------------------------------------------------------
# Options:
# -p = project name
# -a = app name
# -t = time zone
# ----------------------------------------------------------------------
# Requirements:
# - Django
# - Django Crispy Forms
# ----------------------------------------------------------------------

django_boilerplate() {
    # Check for django and crispy forms installation
    FREEZE=`$PIP_CMD freeze`
    django_install=`echo "$FREEZE" | grep -E "Django==[\d.]*"`
    if [ -z "$django_install" ]; then
        echo -e "\nERROR: Django is not installed"
        echo -e "Please install Django"
        echo -e "Run \"pip install django\""
        exit 127
    fi

    crispy_forms_install=`echo "$FREEZE" | grep -E "django-crispy-forms==[\d.]*"`
    if [ -z "$crispy_forms_install" ]; then
        echo -e "\nERROR: Django Crispy Forms is not installed"
        echo -e "Please install Django Crispy Forms"
        echo -e "Run \"pip install django-crispy-forms\""
        exit 127
    fi

    rest_framework_install=`echo "$FREEZE" | grep -E "djangorestframework==[\d.]*"`
    if [ ! -z $SETUP_REST_API ]; then
        if [ -z "$rest_framework_install" ]; then
            echo -e "\nERROR: Django REST framework is not installed"
            echo -e "Please install Django REST framework"
            echo -e "Run \"pip install djangorestframework\""
            exit 127
        fi
    fi

    # Create project
    django-admin startproject $PROJ_NAME

    # Create app
    cd $PROJ_NAME
    $PYTHON_CMD manage.py startapp $APP_NAME

    ACCOUNTS_APP_NAME="accounts"
    # Create accounts app
    $PYTHON_CMD manage.py startapp $ACCOUNTS_APP_NAME

    # Create rest api app
    if [ ! -z $SETUP_REST_API ]; then
        REST_API_APP_NAME="api"
        $PYTHON_CMD manage.py startapp $REST_API_APP_NAME
    fi

    # Get app class name
    APP_CLASS_NAME=`grep -oP "class\s+\K\S+(?=\s*\(\s*\S+\s*\)\s*:)" ${APP_NAME}/apps.py`

    # Get accounts app class name
    ACCOUNTS_APP_CLASS_NAME=`grep -oP "class\s+\K\S+(?=\s*\(\s*\S+\s*\)\s*:)" ${ACCOUNTS_APP_NAME}/apps.py`

    # Get rest api app class name
    if [ ! -z $SETUP_REST_API ]; then
        REST_API_APP_CLASS_NAME=`grep -oP "class\s+\K\S+(?=\s*\(\s*\S+\s*\)\s*:)" ${REST_API_APP_NAME}/apps.py`
    fi

    IFS= read -r -d '' rest_api_apps <<EOS
    '${REST_API_APP_NAME}.apps.${REST_API_APP_CLASS_NAME}',
    'rest_framework',
EOS

    if [ -z $SETUP_REST_API ]; then
        unset rest_api_apps
    fi

    # Add apps to INSTALLED_APPS
    MATCH_LINE=`grep -n INSTALLED_APPS ${PROJ_NAME}/settings.py | cut -f1 -d:`
    ((MATCH_LINE++))
    ex ${PROJ_NAME}/settings.py <<EOF
$MATCH_LINE insert
    '${APP_NAME}.apps.${APP_CLASS_NAME}',
    '${ACCOUNTS_APP_NAME}.apps.${ACCOUNTS_APP_CLASS_NAME}',
${rest_api_apps}    'crispy_forms',
.
xit
EOF

    # Change time zone
    sed -i -E "s/TIME_ZONE\s*=\s*\S+/TIME_ZONE = '${TIME_ZONE}'/g" ${PROJ_NAME}/settings.py

    # Add crispy forms
    echo -e "\nCRISPY_TEMPLATE_PACK = 'bootstrap4'" >> ${PROJ_NAME}/settings.py

    # Add login redirect url
    echo -e "\nLOGIN_REDIRECT_URL = '${APP_NAME}-home'" >> ${PROJ_NAME}/settings.py

    # Configure project urls
    IMPORT_LINE=`grep -n -E "from\s+django\.urls\s+import" ${PROJ_NAME}/urls.py | tail -1 | cut -f1 -d:`
    LINE_CONTENT=`grep -E "from\s+django\.urls\s+import" ${PROJ_NAME}/urls.py | tail -1`
    if [ -z "$LINE_CONTENT" ]; then
        ((IMPORT_LINE++))
        ex ${PROJ_NAME}/urls.py <<EOF
$IMPORT_LINE insert
from django.urls import include
.
xit
EOF
    else
        sed -i "s/${LINE_CONTENT}/${LINE_CONTENT}, include/g" ${PROJ_NAME}/urls.py
    fi

    if [ ! -z $SETUP_REST_API ]; then
        rest_api_url="path('${REST_API_APP_NAME}/', include('${REST_API_APP_NAME}.urls')),"
    fi

    MATCH_LINE=`grep -n -E "urlpatterns" ${PROJ_NAME}/urls.py | tail -1 | cut -f1 -d:`
    ((MATCH_LINE++))
    ex ${PROJ_NAME}/urls.py <<EOF
$MATCH_LINE insert
    path('', include('${APP_NAME}.urls')),
    path('${ACCOUNTS_APP_NAME}/', include('${ACCOUNTS_APP_NAME}.urls')),
    $rest_api_url
.
xit
EOF

    # Configure app urls
    cat <<EOF >> ${APP_NAME}/urls.py
from django.urls import path
from . import views

urlpatterns = [
    path('', views.home, name = '${APP_NAME}-home'),
]
EOF

    # Configure accounts app url
    cat <<EOF >> ${ACCOUNTS_APP_NAME}/urls.py
from django.urls import path
from django.contrib.auth import views as auth_views
from . import views as accounts_views

urlpatterns = [
    path('register/', accounts_views.register, name = '${ACCOUNTS_APP_NAME}-register'),
    path('login/', auth_views.LoginView.as_view(template_name = '${ACCOUNTS_APP_NAME}/login.html'), name = '${ACCOUNTS_APP_NAME}-login'),
    path('logout/', auth_views.LogoutView.as_view(template_name = '${ACCOUNTS_APP_NAME}/logout.html'), name = '${ACCOUNTS_APP_NAME}-logout'),
]
EOF

    # Configure rest api urls
    if [ ! -z $SETUP_REST_API ]; then
        cat <<EOF >> ${REST_API_APP_NAME}/urls.py
from django.urls import path
from . import views

urlpatterns = [
    path('users/', views.UserListCreate.as_view()),
]
EOF
    fi

    # Create base.html
    mkdir -p ${APP_NAME}/templates/${APP_NAME}
    cat > ${APP_NAME}/templates/${APP_NAME}/base.html <<EOF
{% load static %}
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
        <link rel="stylesheet" type="text/css" href="{% static '${APP_NAME}/styles_base.css' %}">
        <title>{% block title %}{% endblock %}</title>
    </head>
    <body>
        <header class="site-header">
            <nav class="navbar navbar-expand-md navbar-dark bg-steel fixed-top">
                <div class="container">
                    <a class="navbar-brand mr-4" href="/">${PROJ_NAME}</a>
                    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarToggle" aria-controls="navbarToggle" aria-expanded="false" aria-label="Toggle navigation">
                        <span class="navbar-toggler-icon"></span>
                    </button>
                    <div class="collapse navbar-collapse" id="navbarToggle">
                        <div class="navbar-nav mr-auto">
                            <a class="nav-item nav-link" href="/">Home</a>
                        </div>
                        <div class="navbar-nav">
                            {% if user.is_authenticated %}
                                <a class="nav-item nav-link" href="#">Welcome, {{ user.first_name }}</a>
                                <a class="nav-item nav-link" href="{% url '${ACCOUNTS_APP_NAME}-logout' %}">Logout</a>
                            {% else %}
                                <a class="nav-item nav-link" href="{% url '${ACCOUNTS_APP_NAME}-login' %}">Login</a>
                                <a class="nav-item nav-link" href="{% url '${ACCOUNTS_APP_NAME}-register' %}">Register</a>
                            {% endif %}
                        </div>
                    </div>
                </div>
            </nav>
        </header>
        <main role="main" class="container">
            <div class="row">
                <div class="col-md-8">
                    {% if messages %}
                        {% for message in messages %}
                            <div class = "alert alert-{{ message.tags }}">
                                {{ message }}
                            </div>
                        {% endfor %}
                    {% endif %}
                    {% block body %}{% endblock %}
                </div>
            </div>
        </main>
        <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>
    </body>
</html>
EOF

    # Create styles_base.css
    mkdir -p ${APP_NAME}/static/${APP_NAME}
    cat > ${APP_NAME}/static/${APP_NAME}/styles_base.css <<EOF
body {
  background: #fafafa;
  color: #333333;
  margin-top: 5rem;
}

h1, h2, h3, h4, h5, h6 {
  color: #444444;
}

ul {
  margin: 0;
}

.bg-steel {
  background-image: linear-gradient(to right, rgb(0, 230, 77) , rgb(51, 204, 204));
}

.site-header .navbar-nav .nav-link {
  color: rgb(242, 242, 242);
}

.site-header .navbar-nav .nav-link:hover {
  color: rgb(255, 255, 255);
}

.site-header .navbar-nav .nav-link.active {
  font-weight: 500;
}

.content-section {
  background: rgb(255, 255, 255);
  padding: 10px 20px;
  border: 1px solid #dddddd;
  border-radius: 3px;
  margin-bottom: 20px;
}
EOF

    # Create home.html
    cat > ${APP_NAME}/templates/${APP_NAME}/home.html <<EOF
{% extends "${APP_NAME}/base.html" %}
{% block title %}
    Home Page
{% endblock %}
{% block body %}
    <h1 class="display-1">Django application</h1>
    <h1 class="display-4">Welcome to the home page!</h1>
{% endblock %}
EOF

    # Create register.html
    mkdir -p ${ACCOUNTS_APP_NAME}/templates/${ACCOUNTS_APP_NAME}
    cat > ${ACCOUNTS_APP_NAME}/templates/${ACCOUNTS_APP_NAME}/register.html <<EOF
{% extends "${APP_NAME}/base.html" %}
{% load crispy_forms_tags %}
{% block title %}
    Register Account
{% endblock %}
{% block body %}
    <div class = "content-section">
        <form method = "POST">
            {% csrf_token %}
            <fieldset class = "form-group">
                <legend class = "border-bottom mb-4">Register for an account</legend>
                {{ form|crispy }}
            </fieldset>
            <div class = "form-group">
                <button class = "btn btn-outline-info" type = "submit">Sign Up</button>
            </div>
        </form>
        <div class = "border-top pt-3">
            <small class = "text-muted">
                Already have an account? <a class = "ml-2" href = "{% url '${ACCOUNTS_APP_NAME}-login' %}">Login</a>
            </small>
        </div>
    </div>
{% endblock %}
EOF

    # Create login.html
    cat > ${ACCOUNTS_APP_NAME}/templates/${ACCOUNTS_APP_NAME}/login.html <<EOF
{% extends "${APP_NAME}/base.html" %}
{% load crispy_forms_tags %}
{% block title %}
    Log In
{% endblock %}
{% block body %}
    <div class = "content-section">
        <form method = "POST">
            {% csrf_token %}
            <fieldset class = "form-group">
                <legend class = "border-bottom mb-4">Log in to your account</legend>
                {{ form|crispy }}
            </fieldset>
            <div class = "form-group">
                <button class = "btn btn-outline-info" type = "submit">Login</button>
            </div>
        </form>
        <div class = "border-top pt-3">
            <small class = "text-muted">
                Don't have an account? <a class = "ml-2" href = "{% url '${ACCOUNTS_APP_NAME}-register' %}"> Sign Up</a>
            </small>
        </div>
    </div>
{% endblock %}
EOF

    # Create logout.html
    cat > ${ACCOUNTS_APP_NAME}/templates/${ACCOUNTS_APP_NAME}/logout.html <<EOF
{% extends "${APP_NAME}/base.html" %}
{% block title %}
    Register Account
{% endblock %}
{% block body %}
    <h1 class = "display-5">You have been logged out.</h1>
    <div class = "border-top pt-3">
        <small class = "text-muted">
            <a class = "ml-2" href = "{% url '${ACCOUNTS_APP_NAME}-login' %}">Log In Again</a>
        </small>
    </div>
{% endblock %}
EOF

    # Create user registration form
    cat > ${ACCOUNTS_APP_NAME}/forms.py <<EOF
from django import forms
from django.contrib.auth.models import User
from django.contrib.auth.forms import UserCreationForm

class UserRegisterForm(UserCreationForm):
    first_name = forms.CharField(label = 'First Name', required = True, help_text = 'Enter first name', widget = forms.TextInput(attrs = {'class' : 'form-control', 'placeholder' : 'eg. Wade'}))
    last_name = forms.CharField(label = 'Last Name', required = True, help_text = 'Enter last name', widget = forms.TextInput(attrs = {'class' : 'form-control', 'placeholder' : 'eg. Wilson'}))
    email = forms.EmailField(label = 'Email', required = True, help_text = 'Enter email address', widget = forms.TextInput(attrs = {'class' : 'form-control', 'placeholder' : 'eg. wwilson@xforce.com'}))

    class Meta:
        model = User
        fields = ['username', 'first_name', 'last_name', 'email', 'password1', 'password2']
        widgets = {
            'username' : forms.TextInput(attrs = {'class' : 'form-control', 'placeholder' : 'eg. wwilson1991'}),
        }
EOF

    # Add views for app
    cat > ${APP_NAME}/views.py <<EOF
from django.shortcuts import render

def home(request):
    return render(request, '${APP_NAME}/home.html')
EOF

    # Add views for accounts
    cat > ${ACCOUNTS_APP_NAME}/views.py <<EOF
from django.shortcuts import render, redirect
from django.contrib import messages
from .forms import UserRegisterForm

def register(request):
    if request.method == 'POST':
        form = UserRegisterForm(request.POST)
        if form.is_valid():
            form.save()
            username = form.cleaned_data.get('username')
            messages.success(request, f'Account created! You may now log in.')
            return redirect('${ACCOUNTS_APP_NAME}-login')
    else:
        form = UserRegisterForm()

    context = {
        'form' : form
    }

    return render(request, '${ACCOUNTS_APP_NAME}/register.html', context)
EOF

    # Add views for rest api
    if [ ! -z $SETUP_REST_API ]; then
        cat > ${REST_API_APP_NAME}/views.py <<EOF
from django.contrib.auth.models import User
from .serializers import UserSerializer
from rest_framework import generics

class UserListCreate(generics.ListCreateAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer
EOF
    fi

    # Create serializers
    if [ ! -z $SETUP_REST_API ]; then
        cat > ${REST_API_APP_NAME}/serializers.py <<EOF
from rest_framework import serializers
from django.contrib.auth.models import User

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = '__all__'
EOF
    fi

    # Apply migrations
    $PYTHON_CMD manage.py migrate > /dev/null
    $PYTHON_CMD manage.py makemigrations > /dev/null
}

# ----------------------------------------------------------------------
# PyQt5 Boilerplate Script
# ----------------------------------------------------------------------
# Options:
# -a = app name
# ----------------------------------------------------------------------
# Requirements:
# - PyQt5
# ----------------------------------------------------------------------

pyqt5_boilerplate() {
    # Check for pyqt5 installation
    pyqt5_install=`$PYTHON_CMD -c "import PyQt5" 2>&1`
    if [ ! -z "$pyqt5_install" ]; then
        echo -e "\nWARNING: PyQt5 is not installed"
        echo -e "Please install PyQt5"
        echo -e "Run \"pip install pyqt5\""
    fi

    # Write to main PyQt5 file
    cat > $APP_NAME.py <<EOF
import sys
from PyQt5.QtWidgets import QMainWindow, QApplication, QWidget, QVBoxLayout, QLabel, QPushButton
from PyQt5.QtCore import Qt

class Window(QMainWindow):
    def __init__(self):
        super().__init__()
        self._width = 500
        self._height = 250
        self._xPos = 700
        self._yPos = 400
        self.initUI()

    def initUI(self):
        self.setGeometry(self._xPos, self._yPos, self._width, self._height)
        self.setWindowTitle("My PyQt5 App")

        self.vBox = QVBoxLayout()

        self.title = QLabel()
        self.title.setText("Welcome to your PyQt5 App!")
        self.title.setAlignment(Qt.AlignCenter)
        self.vBox.addWidget(self.title)

        self.button = QPushButton()
        self.button.setText("Click Me")
        self.button.clicked.connect(self.buttonPressed)
        self.vBox.addWidget(self.button)

        self.centralWidget = QWidget(self)
        self.centralWidget.setLayout(self.vBox)
        self.setCentralWidget(self.centralWidget)

        self.show()

    def buttonPressed(self):
        self.statusBar().showMessage("Button pressed!")

if __name__ == "__main__":
    app = QApplication(sys.argv)
    myWin = Window()
    sys.exit(app.exec_())
EOF
}

print_usage() {
    echo -e "\nUsage: createboilerplate.sh [OPTIONS] <framework_name>"
    echo -e "\nOptions:"
    echo -e "\t-p = project name (Django only)"
    echo -e "\t-a = app name"
    echo -e "\t-d, setup SQLite3 database (Flask only)"
    echo -e "\t-R, setup Django REST Framework (Django only)"
    echo -e "\t-t = time zone (Django only)"
    echo -e "\t-h, show help"
    echo -e "\nSupported frameworks:"
    echo -e "\t- Flask"
    echo -e "\t- Django"
    echo -e "\t- PyQt5"
}

PYTHON_CMD="python"
PIP_CMD="pip"
PROJ_NAME="myproject"
APP_NAME="myapp"
TIME_ZONE="EST"

while getopts "p:a:dRt:h" flag; do
    case "$flag" in
        p)  PROJ_NAME=${OPTARG};;
        a)  APP_NAME=${OPTARG};;
        d)  SETUP_DATABASE="TRUE";;
        R)  SETUP_REST_API="TRUE";;
        t)  TIME_ZONE=${OPTARG};;
        h)  print_usage
            exit 0;;
        *)  exit 128;;
    esac
done

APP=${@:$OPTIND:1}
if [ -z $APP ]; then
    print_usage
    exit 128
fi
APP=${APP,,}

case "$APP" in
    flask)  flask_boilerplate;;
    django) django_boilerplate;;
    pyqt5)  pyqt5_boilerplate;;
    *)      print_usage;;
esac