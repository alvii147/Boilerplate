# Django
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
        echo -e "Please install Crispy Forms"
        echo -e "Run \"pip install django-crispy-forms\""
        exit 127
    fi

    # Create project
    django-admin startproject $PROJ_NAME

    # Create app
    cd $PROJ_NAME
    $PYTHON_CMD manage.py startapp $APP_NAME

    USERS_APP_NAME="users"
    # Create users app
    $PYTHON_CMD manage.py startapp $USERS_APP_NAME

    # Get app class name
    APP_CLASS_NAME=`grep -oP "class\s+\K\S+(?=\s*\(\s*\S+\s*\)\s*:)" ${APP_NAME}/apps.py`

    # Get users app class name
    USERS_APP_CLASS_NAME=`grep -oP "class\s+\K\S+(?=\s*\(\s*\S+\s*\)\s*:)" ${USERS_APP_NAME}/apps.py`

    # Add apps to INSTALLED_APPS
    MATCH_LINE=`grep -n INSTALLED_APPS ${PROJ_NAME}/settings.py | cut -f1 -d:`
    ((MATCH_LINE++))
    ex ${PROJ_NAME}/settings.py <<EOF
$MATCH_LINE insert
    '${APP_NAME}.apps.${APP_CLASS_NAME}',
    '${USERS_APP_NAME}.apps.${USERS_APP_CLASS_NAME}',
    'crispy_forms',
.
xit
EOF

    # Change time zone
    sed -i -E "s/TIME_ZONE\s*=\s*\S+/TIME_ZONE = '${TIME_ZONE}'/g" ${PROJ_NAME}/settings.py

    # Add crispy forms
    echo -e "\nCRISPY_TEMPLATE_PACK = 'bootstrap4'" >> ${PROJ_NAME}/settings.py

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

    MATCH_LINE=`grep -n -E "urlpatterns" ${PROJ_NAME}/urls.py | tail -1 | cut -f1 -d:`
    ((MATCH_LINE++))
    ex ${PROJ_NAME}/urls.py <<EOF
$MATCH_LINE insert
    path('', include('${APP_NAME}.urls')),
    path('register/', include('${USERS_APP_NAME}.urls')),
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

    # Configure users app url
    cat <<EOF >> ${USERS_APP_NAME}/urls.py
from django.urls import path
from . import views

urlpatterns = [
    path('', views.register, name = '${USERS_APP_NAME}-register'),
]
EOF

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
                            <a class="nav-item nav-link" href="#">Login</a>
                            <a class="nav-item nav-link" href="register/">Register</a>
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
  color: rgb(153, 255, 187);
}

.site-header .navbar-nav .nav-link:hover {
  color: #ffffff;
}

.site-header .navbar-nav .nav-link.active {
  font-weight: 500;
}

.content-section {
  background: #ffffff;
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

    # Add views for app
    cat > ${APP_NAME}/views.py <<EOF
from django.shortcuts import render

def home(request):
    return render(request, '${APP_NAME}/home.html')
EOF

    # Create register.html
    mkdir -p ${USERS_APP_NAME}/templates/${USERS_APP_NAME}
    cat > ${USERS_APP_NAME}/templates/${USERS_APP_NAME}/register.html <<EOF
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
                <legend class = "border-bottom mb-4">Register</legend>
                {{ form|crispy }}
            </fieldset>
            <div class = "form-group">
                <button class = "btn btn-outline-info" type = "submit">Sign Up</button>
            </div>
        </form>
        <div class = "border-top pt-3">
            <small class = "text-muted">
                Already have an account? <a class = "ml-2" href = "#"> Sign In</a>
            </small>
        </div>
    </div>
{% endblock %}
EOF

    # Create user registration form
    cat > ${USERS_APP_NAME}/forms.py <<EOF
from django import forms
from django.contrib.auth.models import User
from django.contrib.auth.forms import UserCreationForm

class UserRegisterForm(UserCreationForm):
    email = forms.EmailField()

    class Meta:
        model = User
        fields = ['username', 'email', 'password1', 'password2']
EOF

    # Add user views for app
    cat > ${USERS_APP_NAME}/views.py <<EOF
from django.shortcuts import render, redirect
from django.contrib import messages
from .forms import UserRegisterForm

def register(request):
    if request.method == 'POST':
        form = UserRegisterForm(request.POST)
        if form.is_valid():
            form.save()
            username = form.cleaned_data.get('username')
            messages.success(request, f'Account created for {username}!')
            return redirect('${APP_NAME}-home')
    else:
        form = UserRegisterForm()
    context = {
        'form' : form
    }
    return render(request, '${USERS_APP_NAME}/register.html', context)
EOF

    # Apply migrations
    $PYTHON_CMD manage.py migrate > /dev/null
    $PYTHON_CMD manage.py makemigrations > /dev/null
}

# Flask
flask_boilerplate() {
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
    cat > app.py <<EOF
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

# PyQt5
pyqt5_boilerplate() {
    cat > pyqt5app.py <<EOF
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

PYTHON_CMD="python"
PIP_CMD="pip"
PROJ_NAME="myproject"
APP_NAME="myapp"
TIME_ZONE="EST"

while getopts "dp:a:t:" flag; do
    case "$flag" in
        d) SETUP_DATABASE="TRUE";;
        p) PROJ_NAME=${OPTARG};;
        a) APP_NAME=${OPTARG};;
        t) TIME_ZONE=${OPTARG};;
        *) exit 1;;
    esac
done

APP=${@:$OPTIND:1}
if [ -z $APP ]; then
    echo usage
fi
APP=${APP,,}

case "$APP" in
    flask)  flask_boilerplate;;
    pyqt5)  pyqt5_boilerplate;;
    django) django_boilerplate;;
    *)      echo usage;;
esac