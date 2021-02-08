# ----------------------------------------------------------------------
# Flask Boilerplate Script
# ----------------------------------------------------------------------
# Options:
# -a = app name
# -d,  setup SQLite3 database
# ----------------------------------------------------------------------
# Requirements:
# - Flask
# - Flask SQLAlchemy (if database option included)
# ----------------------------------------------------------------------

flask_boilerplate() {
    # Check for flask and flasksqlalchemy installation
    echo -e "Verifying requirements..."
    flask_install=`$PYTHON_CMD -c "import flask" 2>&1`
    if [ ! -z "$flask_install" ]; then
        echo -e "\nWARNING: Flask is not installed"
        echo -e "Please install Flask"
        echo -e "Run \"pip install flask\""
    else
        echo -e "Found Flask installation"
    fi
    if [ ! -z $SETUP_DATABASE ]; then
        flask_sqlalchemy_install=`$PYTHON_CMD -c "import flask_sqlalchemy" 2>&1`
        if [ ! -z "$flask_sqlalchemy_install" ]; then
            echo -e "\nWARNING: Flask SQLAlchemy is not installed"
            echo -e "Please install Flask SQLAlchemy"
            echo -e "Run \"pip install flask-sqlalchemy\""
        else
            echo -e "Found Flask SQLAlchemy installation"
        fi
    fi

    mkdir -p $APP_NAME
    cd $APP_NAME

    # Random string for secret key
    echo -e "Generating secret key..."
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

    # Write to main app file
    echo -e "Creating $APP_NAME.py..."
    cat <<EOF > $APP_NAME.py
from flask import Flask, render_template
${import_sqlalchemy}
app = Flask(__name__)
app.secret_key = "${secret_key}"
${db_config}${user_model}
@app.route("/")
def home():
    return render_template("home.html")

if __name__ == "__main__":
${db_create_all}    app.run(debug=True)
EOF

    # HTML templates
    echo -e "Creating home.html..."
    mkdir -p templates
    cd templates
    cat <<EOF > home.html
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
    echo -e "Creating styles.css..."
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
# -R,  setup Django REST framework
# -r,  setup ReactJS frontend
# -t = time zone
# ----------------------------------------------------------------------
# Requirements:
# - Django
# - Django Crispy Forms
# - Django REST framework (if REST API or ReactJS option included)
# ----------------------------------------------------------------------

django_boilerplate() {
    # Check for django installation
    echo -e "Verifying requirements..."
    FREEZE=`$PIP_CMD freeze 2>&1`
    django_install=`echo "$FREEZE" | grep -E "Django==[\d.]*"`
    if [ -z "$django_install" ]; then
        echo -e "\nERROR: Django is not installed"
        echo -e "Please install Django"
        echo -e "Run \"pip install django\""
        requirements_err=1
    else
        if [[ ! "$requirements_err" -eq 1 ]]; then
            echo -e "Found Django installation"
        fi
    fi

    # Check for crispy forms installation
    crispy_forms_install=`echo "$FREEZE" | grep -E "django-crispy-forms==[\d.]*"`
    if [ -z "$crispy_forms_install" ]; then
        echo -e "\nERROR: Django Crispy Forms is not installed"
        echo -e "Please install Django Crispy Forms"
        echo -e "Run \"pip install django-crispy-forms\""
        requirements_err=1
    else
        if [[ ! "$requirements_err" -eq 1 ]]; then
            echo -e "Found Django Crispy Forms installation"
        fi
    fi

    # Check for django rest framework installation
    if [ ! -z $SETUP_REST_API ]; then
        rest_framework_install=`echo "$FREEZE" | grep -E "djangorestframework==[\d.]*"`
        if [ -z "$rest_framework_install" ]; then
            echo -e "\nERROR: Django REST framework is not installed"
            echo -e "Please install Django REST framework"
            echo -e "Run \"pip install djangorestframework\""
            requirements_err=1
        else
            if [[ ! "$requirements_err" -eq 1 ]]; then
                echo -e "Found Django REST framework installation"
            fi
        fi
    fi

    # Check for npm installation
    if [ ! -z $SETUP_REACT ]; then
        which npm >/dev/null 2>&1
        if [[ "$?" -ne 0 ]]; then
            echo -e "\nERROR: npm is not installed"
            echo -e "Please install npm"
            echo -e "https://nodejs.org/en/download/"
            requirements_err=1
        else
            if [[ ! "$requirements_err" -eq 1 ]]; then
                echo -e "Found npm installation"
            fi
        fi
    fi

    if [[ "$requirements_err" -eq 1 ]]; then
        exit 127
    fi

    # Create project
    echo -e "Creating Django project $PROJ_NAME..."
    django-admin startproject $PROJ_NAME

    # Create app
    echo -e "Creating Django app $APP_NAME..."
    cd $PROJ_NAME
    $PYTHON_CMD manage.py startapp $APP_NAME

    # Get app class name
    APP_CLASS_NAME=`grep -oP "class\s+\K\S+(?=\s*\(\s*\S+\s*\)\s*:)" ${APP_NAME}/apps.py`

    # Creating frontend ReactJS app
    FRONTEND_APP_NAME="frontend"
    if [ ! -z $SETUP_REACT ]; then
        echo -e "Creating frontend ReactJS app $FRONTEND_APP_NAME..."
        $PYTHON_CMD manage.py startapp $FRONTEND_APP_NAME
    fi

    IFS= read -r -d '' rest_framework_app <<EOS
    'rest_framework',
EOS
    if [ -z $SETUP_REST_API ]; then
        unset rest_framework_app
    fi

    IFS= read -r -d '' frontend_app <<EOS
    '${FRONTEND_APP_NAME}',
EOS

    if [ -z $SETUP_REACT ]; then
        unset frontend_app
    fi

    if [ -z $SETUP_REACT ]; then
        main_url_path="${APP_NAME}.app_urls"
        main_url_name="app-home"
    else
        main_url_path="${FRONTEND_APP_NAME}.urls"
        main_url_name="frontend-index"
    fi

    # Add apps to INSTALLED_APPS
    echo -e "Adding apps to INSTALLED_APPS in settings.py..."
    MATCH_LINE=`grep -n INSTALLED_APPS ${PROJ_NAME}/settings.py | cut -f1 -d:`
    ((MATCH_LINE++))
    ex ${PROJ_NAME}/settings.py <<EOF
$MATCH_LINE insert
    '${APP_NAME}.apps.${APP_CLASS_NAME}',
${rest_framework_app}${frontend_app}    'crispy_forms',
.
xit
EOF

    # Change time zone
    echo -e "Setting time zone..."
    sed -i -E "s/TIME_ZONE\s*=\s*\S+/TIME_ZONE = '${TIME_ZONE}'/g" ${PROJ_NAME}/settings.py

    # Add crispy forms
    echo -e "Setting crispy forms bootstrap version..."
    echo -e "\nCRISPY_TEMPLATE_PACK = 'bootstrap4'" >> ${PROJ_NAME}/settings.py

    # Add login redirect url
    echo -e "Setting login redirect URL..."
    echo -e "\nLOGIN_REDIRECT_URL = '${main_url_name}'" >> ${PROJ_NAME}/settings.py

    # Configure project urls
    echo -e "Setting up project URLs..."
    if [ ! -z $SETUP_REST_API ]; then
        IFS= read -r -d '' rest_api_url <<EOS
    path('api/', include('${APP_NAME}.api_urls')),
EOS
    fi

    cat <<EOF > ${PROJ_NAME}/urls.py
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('', include('${main_url_path}')),
    path('accounts/', include('${APP_NAME}.accounts_urls')),
${rest_api_url}    path('admin/', admin.site.urls),
]
EOF

    # Configure app urls
    echo -e "Setting up app URLs..."
    cat <<EOF > ${APP_NAME}/app_urls.py
from django.urls import path
from . import views

urlpatterns = [
    path('', views.home, name = '${main_url_name}'),
]
EOF

    # Configure accounts app url
    echo -e "Setting up accounts URLs..."
    cat <<EOF > ${APP_NAME}/accounts_urls.py
from django.urls import path
from django.contrib.auth import views as auth_views
from . import views

urlpatterns = [
    path('register/', views.register, name = 'accounts-register'),
    path('login/', auth_views.LoginView.as_view(template_name = '${APP_NAME}/login.html'), name = 'accounts-login'),
    path('logout/', auth_views.LogoutView.as_view(template_name = '${APP_NAME}/logout.html'), name = 'accounts-logout'),
]
EOF

    # Configure rest api urls
    if [ ! -z $SETUP_REST_API ]; then
        echo -e "Setting up REST API URLs..."
        cat <<EOF > ${APP_NAME}/api_urls.py
from django.urls import path
from . import views

urlpatterns = [
    path('users/', views.UserListCreate.as_view(), name = 'api-users-list-create'),
    path('users/<int:pk>/', views.UserGetUpdateDelete.as_view(), name = 'api-users-get-update-delete'),
]
EOF
    fi

    # Configure frontend urls
    if [ ! -z $SETUP_REACT ]; then
        echo -e "Setting up frontend URLs"
        cat <<EOF > ${FRONTEND_APP_NAME}/urls.py
from django.urls import path
from . import views

urlpatterns = [
    path('', views.index , name = '${main_url_name}'),
]
EOF
    fi

    # Create base.html
    echo -e "Creating base.html..."
    mkdir -p ${APP_NAME}/templates/${APP_NAME}
    cat <<EOF > ${APP_NAME}/templates/${APP_NAME}/base.html
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
                    <a class="navbar-brand mr-4" href="/">django_proj</a>
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
                                <a class="nav-item nav-link" href="{% url 'accounts-logout' %}">Logout</a>
                            {% else %}
                                <a class="nav-item nav-link" href="{% url 'accounts-login' %}">Login</a>
                                <a class="nav-item nav-link" href="{% url 'accounts-register' %}">Register</a>
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
        {% block src %}{% endblock %}
    </body>
</html>
EOF

    # Create styles_base.css
    echo -e "Creating styles_base.css..."
    mkdir -p ${APP_NAME}/static/${APP_NAME}
    cat  <<EOF > ${APP_NAME}/static/${APP_NAME}/styles_base.css
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
    echo -e "Creating home.html..."
    cat <<EOF > ${APP_NAME}/templates/${APP_NAME}/home.html
{% extends "${APP_NAME}/base.html" %}
{% block title %}
    Home Page
{% endblock %}
{% block body %}
    <h1 class="display-1">Django application</h1>
    <h1 class="display-4">Welcome to the home page!</h1>
{% endblock %}
{% block src %}
{% endblock %}
EOF

    # Create register.html
    echo -e "Creating register.html..."
    cat <<EOF > ${APP_NAME}/templates/${APP_NAME}/register.html
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
                Already have an account? <a class = "ml-2" href = "{% url 'accounts-login' %}">Login</a>
            </small>
        </div>
    </div>
{% endblock %}
{% block src %}
{% endblock %}
EOF

    # Create login.html
    echo -e "Creating login.html..."
    cat <<EOF > ${APP_NAME}/templates/${APP_NAME}/login.html
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
                Don't have an account? <a class = "ml-2" href = "{% url 'accounts-register' %}"> Sign Up</a>
            </small>
        </div>
    </div>
{% endblock %}
{% block src %}
{% endblock %}
EOF

    # Create logout.html
    echo -e "Creating logout.html..."
    cat <<EOF > ${APP_NAME}/templates/${APP_NAME}/logout.html
{% extends "${APP_NAME}/base.html" %}
{% block title %}
    Register Account
{% endblock %}
{% block body %}
    <h1 class = "display-5">You have been logged out.</h1>
    <div class = "border-top pt-3">
        <small class = "text-muted">
            <a class = "ml-2" href = "{% url 'accounts-login' %}">Log In Again</a>
        </small>
    </div>
{% endblock %}
{% block src %}
{% endblock %}
EOF

    # Create frontend index.html
    if [ ! -z $SETUP_REACT ]; then
        echo -e "Creating index.html..."
        mkdir -p ${FRONTEND_APP_NAME}/{static,templates}/${FRONTEND_APP_NAME}
        cat <<EOF > ${FRONTEND_APP_NAME}/templates/${FRONTEND_APP_NAME}/index.html
{% extends "${APP_NAME}/base.html" %}
{% block title %}
    Home Page
{% endblock %}
{% block body %}
    <div id="app">
    </div>
{% endblock %}
{% block src %}
    {% load static %}
    <script src="{% static '${FRONTEND_APP_NAME}/main.js' %}"></script>
{% endblock %}
EOF
    fi

    # Create user registration form
    echo -e "Creating user registrations form..."
    cat <<EOF > ${APP_NAME}/forms.py
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
    echo -e "Writing app views..."
    cat <<EOF > ${APP_NAME}/views.py
from django.shortcuts import render, redirect
from django.contrib import messages
from .forms import UserRegisterForm
EOF

    if [ ! -z $SETUP_REST_API ]; then
        cat <<EOF >> ${APP_NAME}/views.py
from django.contrib.auth.models import User
from .serializers import UserSerializer
from rest_framework import generics
EOF
    fi

    cat <<EOF >> ${APP_NAME}/views.py

def home(request):
    return render(request, '${APP_NAME}/home.html')

def register(request):
    if request.method == 'POST':
        form = UserRegisterForm(request.POST)
        if form.is_valid():
            form.save()
            username = form.cleaned_data.get('username')
            messages.success(request, f'Account created! You may now log in.')
            return redirect('accounts-login')
    else:
        form = UserRegisterForm()

    context = {
        'form' : form
    }

    return render(request, '${APP_NAME}/register.html', context)
EOF

    if [ ! -z $SETUP_REST_API ]; then
        cat <<EOF >> ${APP_NAME}/views.py

class UserListCreate(generics.ListCreateAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer

class UserGetUpdateDelete(generics.RetrieveUpdateDestroyAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer
EOF
    fi

    if [ ! -z $SETUP_REACT ]; then
        cat <<EOF > ${FRONTEND_APP_NAME}/views.py
from django.shortcuts import render

def index(request):
    return render(request, '${FRONTEND_APP_NAME}/index.html')
EOF
    fi

    # Create serializers
    if [ ! -z $SETUP_REST_API ]; then
        echo -e "Creating serializers..."
        cat <<EOF > ${APP_NAME}/serializers.py
from rest_framework import serializers
from django.contrib.auth.models import User

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = '__all__'
EOF
    fi

    # Apply migrations
    echo -e "Creating migrations..."
    $PYTHON_CMD manage.py makemigrations
    echo -e "Migrating..."
    $PYTHON_CMD manage.py migrate

    # Integrate react using webpack and babel
    if [ ! -z $SETUP_REACT ]; then
        cd ${FRONTEND_APP_NAME}
        mkdir -p src/components

        npm init -y
        # Install webpack and webpack cli
        echo -e "Installing webpack and webpack cli..."
        npm i webpack webpack-cli --save-dev

        # Configure dev and production webpack scripts
        echo -e "Configuring dev and production webpack scripts..."
        MATCH_LINE=`grep -En "\"scripts\"\s*:\s*{" package.json | cut -f1 -d:`
        ((MATCH_LINE++))
        ex package.json <<EOF
$MATCH_LINE insert
    "dev": "webpack --mode development --entry ./src/index.js --output-path ./static/${FRONTEND_APP_NAME}",
    "build": "webpack --mode production --entry ./src/index.js --output-path ./static/${FRONTEND_APP_NAME}",
.
xit
EOF

        # Install babel
        echo -e "Installing babel..."
        npm i @babel/core babel-loader @babel/preset-env @babel/preset-react --save-dev

        # Configure babel
        echo -e "Configuring babel..."
        cat <<EOF > .babelrc
{
    "presets": [
        "@babel/preset-env", "@babel/preset-react"
    ]
}
EOF

        # Install react, react-dom and react-router-dom
        echo -e "Installing react, react-dom and react-router-dom..."
        npm i react react-dom react-router-dom --save-dev

        # Configure babel loader in webpack configuration
        echo -e "Configuring babel loader in webpack configuration..."
        cat <<EOF > webpack.config.js
module.exports = {
    module: {
        rules: [
            {
                test: /\.js$/,
                exclude: /node_modules/,
                use: {
                    loader: "babel-loader"
                }
            }
        ]
    }
};
EOF

        # Create index.js
        echo -e "Creating index.js..."
        cat <<EOF > src/index.js
import App from "./components/App";
EOF

        # Create App.js
        echo -e "Creating App.js..."
        cat <<EOF > src/components/App.js
import React, { Component } from "react";
import { render } from "react-dom";
//import { BrowserRouter as Router, Switch, Route } from "react-router-dom";

class App extends Component {
    constructor(props) {
        super(props);
        this.state = {
            readAllData: [],
            readData: [],
            postData: {},
            id: ""
        };
        this.handleChange = this.handleChange.bind(this);
        //this.handleSubmit = this.handleSubmit.bind(this);
        this.CreateUserAPI = this.CreateUserAPI.bind(this);
        this.ReadAllUsersAPI = this.ReadAllUsersAPI.bind(this);
        this.ReadUserAPI = this.ReadUserAPI.bind(this);
        this.UpdateUserAPI = this.UpdateUserAPI.bind(this);
        this.DeleteUserAPI = this.DeleteUserAPI.bind(this);
    }

    componentDidMount() {
        //this.ReadAllUsersAPI();
    }

    handleChange(event) {
        const data = this.state.postData;
        if(event.target.name == "id") {
            this.setState({
                id: event.target.value
            })
            return
        }
        
        if(event.target.name == "status") {
            if(event.target.checked) {
                data["status"] = true;
            }
            else {
                data["status"] = false;
            }
        }
        else {
            if(!event.target.name && data.hasOwnProperty(event.target.name)) {
                delete data[event.target.name];
            }
            else {
                data[event.target.name] = event.target.value;
            }
        }
        this.setState({
            postData: data
        });
    }

    /*handleSubmit(event) {
        event.preventDefault();
    }*/

    CreateUserAPI() {
        console.log("Creating...");
        fetch("/api/users/", {
            method: "POST",
            body: JSON.stringify(this.state.postData),
            headers: {
                "Content-type": "application/json; charset=UTF-8"
            }
        })
        .then(response => {
            if (response.status > 400) {
                console.log("Error in POST request");
            }
            return response.json();
        })
        .then(json => {
            console.log(json);
            this.ReadAllUsersAPI();
        });
    }

    ReadAllUsersAPI() {
        console.log("Reading...");
        fetch("/api/users/")
        .then(response => {
            if (response.status > 400) {
                console.log("Error in GET request");
            }
            return response.json();
        })
        .then(json => {
            console.log(json);
            this.setState({
                readAllData: json
            });
        });
    }

    ReadUserAPI() {
        console.log("Reading Single Entry...");
        fetch("/api/users/" + this.state.id + "/")
        .then(response => {
            if (response.status > 400) {
                console.log("Error in GET request");
            }
            return response.json();
        })
        .then(json => {
            console.log(json);
            this.setState({
                readData: json
            });
        });
    }

    UpdateUserAPI() {
        console.log("Updating...");
        fetch("/api/users/" + this.state.id + "/", {
            method: "PATCH",
            body: JSON.stringify(this.state.postData),
            headers: {
                "Content-type": "application/json; charset=UTF-8"
            }
        })
        .then(response => {
            if (response.status > 400) {
                console.log("Error in PATCH request");
            }
            return response.json();
        })
        .then(json => {
            console.log(json);
            this.ReadAllUsersAPI();
        });
    }

    DeleteUserAPI() {
        console.log("Deleting...");
        fetch("/api/users/" + this.state.id + "/", {
            method: "DELETE"
        })
        .then(response => {
            console.log(response);
            this.ReadAllUsersAPI();
        });
    }

    render() {
        return (
            <div>
                <h1 className="display-1">Django application</h1>
                <h1 className="display-4">Welcome to the home page!</h1>
            </div>
        );
    }
}

export default App;

const container = document.getElementById("app");
render(<App />, container);
EOF

        # Run webpack
        echo -e "Running webpack..."
        npm run dev

        # Create frontend gitignore
        echo -e "Creating gitignore for frontend app..."
        cat <<EOF > .gitignore
.idea/
.vscode/
node_modules/
build
.DS_Store
*.tgz
my-app*
template/src/__tests__/__snapshots__/
lerna-debug.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
/.changelog
.npm/
yarn.lock
EOF

        # Create launch script
        cd ..
        echo -e "Creating launch script..."
        cat <<EOF > launch.sh
PYTHON_CMD="python3"
which \$PYTHON_CMD >/dev/null 2>&1
if [[ "\$?" -ne 0 ]]; then
    PYTHON_CMD="python"
fi

SCRIPT_DIR=\`dirname \${BASH_SOURCE[0]}\`
cd \$SCRIPT_DIR

set -e

\$PYTHON_CMD manage.py makemigrations
\$PYTHON_CMD manage.py migrate

cd $FRONTEND_APP_NAME
npm run dev

cd ..
\$PYTHON_CMD manage.py runserver
EOF
    fi

    # Create main gitignore
    echo -e "Creating gitignore for top directory..."
    cat <<EOF > .gitignore
env/
__pycache__/
*.sqlite3
EOF

    echo -e "\nFinished creating Django project!"
    if [ ! -z $SETUP_REACT ]; then
        echo -e "ReactJS frontend integrations successful"
        echo -e "Do a 'cd $PROJ_NAME' and then try './launch.sh'"
        echo -e "And open up http://localhost:8000 on your browser!"
    fi
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
    echo -e "Verifying requirements..."
    pyqt5_install=`$PYTHON_CMD -c "import PyQt5" 2>&1`
    if [ ! -z "$pyqt5_install" ]; then
        echo -e "\nWARNING: PyQt5 is not installed"
        echo -e "Please install PyQt5"
        echo -e "Run \"pip install pyqt5\""
    else
        echo -e "Found PyQt5 installation"
    fi

    mkdir -p $APP_NAME
    cd $APP_NAME

    # Write to main PyQt5 file
    echo -e "Creating $APP_NAME.py..."
    cat <<EOF > $APP_NAME.py
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

# ----------------------------------------------------------------------
# React Native Boilerplate Script
# ----------------------------------------------------------------------
# Options:
# -a = app name
# ----------------------------------------------------------------------
# Requirements:
# - npm
# - expo cli
# ----------------------------------------------------------------------

reactnative_boilerplate() {
    # Check for npm installation
    which npm >/dev/null 2>&1
    if [[ "$?" -ne 0 ]]; then
        echo -e "\nERROR: npm is not installed"
        echo -e "Please install npm"
        echo -e "https://nodejs.org/en/download/"
        requirements_err=1
    else
        if [[ ! "$requirements_err" -eq 1 ]]; then
            echo -e "Found npm installation"
        fi
    fi

    # Checking for expo cli installation
    which expo >/dev/null 2>&1
    if [[ "$?" -ne 0 ]]; then
        echo -e "\nERROR: expo cli is not installed"
        echo -e "Run \"npm install -g expo-cli\""
        requirements_err=1
    else
        if [[ ! "$requirements_err" -eq 1 ]]; then
            echo -e "Found expo cli installation"
        fi
    fi

    if [[ "$requirements_err" -eq 1 ]]; then
        exit 127
    fi

    # Create new expo app
    echo -e "Creating expo app..."
    expo init $APP_NAME --template blank
    cd $APP_NAME

    # Install react native paper
    echo -e "Installing react-native-paper..."
    npm install react-native-paper

    # Install react native navigation
    echo -e "Installing react-native-navigation..."
    npm install react-navigation
    expo install react-native-gesture-handler
    expo install react-native-reanimated
    expo install react-native-screens
    expo install react-native-safe-area-context
    expo install @react-native-community/masked-view
    npm install react-navigation-stack
    npm install react-navigation-material-bottom-tabs


    # Install react native vector icons
    echo -e "Installing react-native-vector-icons..."
    npm install react-native-vector-icons

    # Writing App.js
    echo -e "Writing App.js..."
    cat <<EOF > App.js
import React, { Component } from 'react';
import AppContainer from './src/routes/AppContainer';

export default class App extends Component {
    state = {
        isUserAuth: false,
    }

    componentDidMount() {
        //this.setState({isUserAuth: true});
    }

    render() {
        return (
            <AppContainer />
        );
    }
}
EOF

    mkdir -p src/{constants,routes,screens}

    cd src/routes
    # Writing AppContainer.js
    echo -e "Writing AppContainer.js..."
    cat <<EOF > AppContainer.js
import { createAppContainer, createSwitchNavigator } from 'react-navigation';
import AuthStack from './AuthStack';
import AppStack from './AppStack';

export default createAppContainer (
    createSwitchNavigator
    (
        {
            Auth: AuthStack,
            App: AppStack,
        },
        {
            initialRouteName: 'Auth',
        }
    )
);
EOF

    # Writing AuthStack.js
    echo -e "Writing AuthStack.js..."
    cat <<EOF > AuthStack.js
import { createStackNavigator } from 'react-navigation-stack';
import Login from '../screens/Login';
import Register from '../screens/Register';

const AuthScreens = {
    Login: {
        screen: Login,
        navigationOptions: {
            header: () => false,
        },
    },
    Register: {
        screen: Register,
        navigationOptions: {
            header: () => false,
        },
    }
}

export default createStackNavigator(AuthScreens);
EOF

    # Writing AppStack.js
    echo -e "Writing AppStack.js..."
    cat <<EOF > AppStack.js
import { createMaterialBottomTabNavigator } from 'react-navigation-material-bottom-tabs';
import React from 'react';
import { View } from 'react-native';
import Icon from 'react-native-vector-icons/Ionicons';
import Colors from '../constants/Colors';
import Home from '../screens/Home';
import Profile from '../screens/Profile';
import Notifications from '../screens/Notifications';
import Settings from '../screens/Settings';

const AppScreens = {
    Home: {
        screen: Home,
        navigationOptions: {
            tabBarLabel: 'Home',
            tabBarIcon: () => (
                <View>
                    <Icon style={[{color: Colors.tabIcon}]} size={25} name={'home'} />
                </View>
            ),
            activeColor: Colors.tabIcon,
            barStyle: {
                backgroundColor: Colors.primary,
            },
        },
    },
    Profile: {
        screen: Profile,
        navigationOptions: {
            tabBarLabel: 'Profile',
            tabBarIcon: () => (
                <View>
                    <Icon style={[{color: Colors.tabIcon}]} size={25} name={'person-circle'} />
                </View>
            ),
            activeColor: Colors.tabIcon,
            barStyle: {
                backgroundColor: Colors.primary,
            },
        },
    },
    Notifications: {
        screen: Notifications,
        navigationOptions: {
            tabBarLabel: 'Home',
            tabBarIcon: () => (
                <View>
                    <Icon style={[{color: Colors.tabIcon}]} size={25} name={'notifications'} />
                </View>
            ),
            activeColor: Colors.tabIcon,
            barStyle: {
                backgroundColor: Colors.primary,
            },
        },
    },
    Settings: {
        screen: Settings,
        navigationOptions: {
            tabBarLabel: 'Settings',
            tabBarIcon: () => (
                <View>
                    <Icon style={[{color: Colors.tabIcon}]} size={25} name={'settings'} />
                </View>
            ),
            activeColor: Colors.tabIcon,
            barStyle: {
                backgroundColor: Colors.primary,
            },
        },
    },
}

export default createMaterialBottomTabNavigator(AppScreens);
EOF

    cd ../screens
    # Writing Login.js
    echo -e "Writing Login.js..."
    cat <<EOF > Login.js
import React, { Component } from 'react';
import { StyleSheet, Text, View, Image, Keyboard, TouchableWithoutFeedback, TouchableOpacity } from 'react-native';
import { TextInput, Button } from 'react-native-paper';
import Colors from '../constants/Colors';

export default class Login extends Component {
    constructor(props) {
        super(props);
        this.state = {
            username: '',
            password: '',
        };
        this.loginButtonPressHandler.bind(this);
    }

    loginButtonPressHandler = async () => {
        this.props.navigation.navigate('App');
    };

    render() {
        return (
            <TouchableWithoutFeedback onPress={() => {
                Keyboard.dismiss();
            }}>
                <View style={styles.container}>
                    <View style={styles.logoContainer}>
                        <Image source={require('../../assets/react_logo.png')} style={styles.logo}></Image>
                    </View>
                    <View style={styles.loginContainer}>
                        <TextInput
                            style={styles.textInputBox}
                            label='Username'
                            value={this.state.username}
                            placeholder='e.g. wwilson1991'
                            mode='outlined'
                            selectionColor={Colors.primary}
                            underlineColor={Colors.primary}
                            theme={{
                                colors: {
                                    primary: Colors.primary,
                                },
                            }}
                            onChangeText={username => this.setState({ username: username })} />
                        <TextInput
                            style={styles.textInputBox}
                            label='Password'
                            value={this.state.password}
                            secureTextEntry={true}
                            placeholder='e.g. 9#7@P+d3N%'
                            mode='outlined'
                            selectionColor={Colors.primary}
                            underlineColor={Colors.primary}
                            theme={{
                                colors: {
                                    primary: Colors.primary,
                                },
                            }}
                            onChangeText={password => this.setState({ password: password })} />
                    </View>
                    <View style={styles.buttonWrapper}>
                        <Button
                            onPress={this.loginButtonPressHandler}
                            mode='contained'
                            color={Colors.primary}>
                                Log in
                        </Button>
                    </View>
                    <View style={styles.registerWrapper}>
                        <Text>
                            Need an account?&nbsp;
                            <Text style={styles.registerText} onPress={() => {this.props.navigation.navigate('Register');}}>
                                Register
                            </Text>
                        </Text>
                    </View>
                </View>
            </TouchableWithoutFeedback>
        )
    }
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: Colors.secondary,
        alignItems: 'center',
        justifyContent: 'center',
    },

    logoContainer: {
        flex: 6,
        alignItems: 'center',
        justifyContent: 'center',
    },

    logo: {
        width: 160,
        height: 160,
    },

    loginContainer: {
        flex: 2,
        justifyContent: 'center',
        width: 250,
        height: 153,
    },

    textInputBox: {
        paddingTop: 5,
        paddingBottom: 5,
    },

    buttonWrapper: {
        flex: 2,
        justifyContent: 'flex-end',
    },

    registerWrapper: {
        flex: 3,
        paddingTop: 15,
    },

    registerText: {
        color: Colors.primary,
    },
});
EOF

    # Writing Register.js
    echo -e "Writing Register.js..."
    cat <<EOF > Register.js
import React, { Component } from 'react';
import { StyleSheet, Text, View, Image, Keyboard, TouchableWithoutFeedback, TouchableOpacity } from 'react-native';
import { TextInput, Button } from 'react-native-paper';
import Colors from '../constants/Colors';

export default class Login extends Component {
    constructor(props) {
        super(props);
        this.state = {
            firstname: '',
            lastname: '',
            username: '',
            password: '',
        };
        this.registerButtonPressHandler.bind(this);
    }

    registerButtonPressHandler = async () => {
        this.props.navigation.navigate('Login');
    };

    render() {
        return (
            <TouchableWithoutFeedback onPress={() => {
                Keyboard.dismiss();
            }}>
                <View style={styles.container}>
                    <View style={styles.logoContainer}>
                        <Image source={require('../../assets/react_logo.png')} style={styles.logo}></Image>
                    </View>
                    <View style={styles.registerContainer}>
                        <TextInput
                            style={styles.textInputBox}
                            label='First Name'
                            value={this.state.firstname}
                            placeholder='e.g. Wade'
                            mode='outlined'
                            selectionColor={Colors.primary}
                            underlineColor={Colors.primary}
                            theme={{
                                colors: {
                                    primary: Colors.primary,
                                },
                            }}
                            onChangeText={firstname => this.setState({ firstname: firstname })} />
                        <TextInput
                            style={styles.textInputBox}
                            label='Last Name'
                            value={this.state.lastname}
                            placeholder='e.g. Wilson'
                            mode='outlined'
                            selectionColor={Colors.primary}
                            underlineColor={Colors.primary}
                            theme={{
                                colors: {
                                    primary: Colors.primary,
                                },
                            }}
                            onChangeText={lastname => this.setState({ lastname: lastname })} />
                        <TextInput
                            style={styles.textInputBox}
                            label='Username'
                            value={this.state.username}
                            placeholder='e.g. wwilson1991'
                            mode='outlined'
                            selectionColor={Colors.primary}
                            underlineColor={Colors.primary}
                            theme={{
                                colors: {
                                    primary: Colors.primary,
                                },
                            }}
                            onChangeText={username => this.setState({ username: username })} />
                        <TextInput
                            style={styles.textInputBox}
                            label='Password'
                            value={this.state.password}
                            secureTextEntry={true}
                            placeholder='e.g. 9#7@P+d3N%'
                            mode='outlined'
                            selectionColor={Colors.primary}
                            underlineColor={Colors.primary}
                            theme={{
                                colors: {
                                    primary: Colors.primary,
                                },
                            }}
                            onChangeText={password => this.setState({ password: password })} />
                    </View>
                    <View style={styles.buttonWrapper}>
                        <Button
                            onPress={this.registerButtonPressHandler}
                            mode='contained'
                            color={Colors.primary}>
                                Register
                        </Button>
                    </View>
                    <View style={styles.loginWrapper}>
                        <Text>
                            Already have an account?&nbsp;
                            <Text style={styles.loginText} onPress={() => {this.props.navigation.navigate('Login');}}>
                                Log in
                            </Text>
                        </Text>
                    </View>
                </View>
            </TouchableWithoutFeedback>
        )
    }
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: Colors.secondary,
        alignItems: 'center',
        justifyContent: 'center',
    },

    logoContainer: {
        flex: 6,
        alignItems: 'center',
        justifyContent: 'center',
    },

    logo: {
        width: 160,
        height: 160,
    },

    registerContainer: {
        flex: 2,
        justifyContent: 'center',
        width: 250,
        height: 153,
    },

    textInputBox: {
        paddingTop: 5,
        paddingBottom: 5,
    },

    buttonWrapper: {
        flex: 3,
        justifyContent: 'flex-end',
    },

    loginWrapper: {
        flex: 2,
        paddingTop: 15,
    },

    loginText: {
        color: Colors.primary,
    },
});
EOF

    # Writing Home.js
    echo -e "Writing Home.js..."
    cat <<EOF > Home.js
import React, { Component } from 'react';
import { StyleSheet, View, Text } from 'react-native';
import Colors from '../constants/Colors';

export default class Home extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        return (
            <View style={styles.container}>
                <Text>
                    Home Tab!
                </Text>
            </View>
        );
    }
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: Colors.secondary,
        alignItems: 'center',
        justifyContent: 'center',
    },
});
EOF

    # Writing Profile.js
    echo -e "Writing Profile.js..."
    cat <<EOF > Profile.js
import React, { Component } from 'react';
import { StyleSheet, View, Text } from 'react-native';
import Colors from '../constants/Colors';

export default class Home extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        return (
            <View style={styles.container}>
                <Text>
                    Profile Tab!
                </Text>
            </View>
        );
    }
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: Colors.secondary,
        alignItems: 'center',
        justifyContent: 'center',
    },
});
EOF

    # Writing Notifications.js
    echo -e "Writing Notifications.js..."
    cat <<EOF > Notifications.js
import React, { Component } from 'react';
import { StyleSheet, View, Text } from 'react-native';
import Colors from '../constants/Colors';

export default class Home extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        return (
            <View style={styles.container}>
                <Text>
                    Notifications Tab!
                </Text>
            </View>
        );
    }
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: Colors.secondary,
        alignItems: 'center',
        justifyContent: 'center',
    },
});
EOF

    # Writing Settings.js
    echo -e "Writing Settings.js..."
    cat <<EOF > Settings.js
import React, { Component } from 'react';
import { StyleSheet, View, Text } from 'react-native';
import Colors from '../constants/Colors';

export default class Home extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        return (
            <View style={styles.container}>
                <Text>
                    Settings Tab!
                </Text>
            </View>
        );
    }
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: Colors.secondary,
        alignItems: 'center',
        justifyContent: 'center',
    },
});
EOF

    cd ../constants
    # Writing Colors.js
    echo -e "Writing Colors.js..."
    cat <<EOF > Colors.js
const primary = '#61dafb';
const secondary = '#ccd9ff';
const tabIcon = '#000000';

export default {
    primary,
    secondary,
    tabIcon,
}
EOF

    cd ../../assets
    # Download react logo
    echo -e "Downloading react logo"
    curl https://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/React-icon.svg/1280px-React-icon.svg.png > react_logo.png

    echo -e "\nFinished creating react native project!"
    echo -e "Try navigating into app directory and running"
    echo -e "\"npm start\" or \"expo start\""
}

print_usage() {
    echo -e "\nUsage: createboilerplate.sh [OPTIONS] <framework_name>"
    echo -e "\nOptions:"
    echo -e "\t-p = project name (Django only)"
    echo -e "\t-a = app name"
    echo -e "\t-d,  setup SQLite3 database (Flask only)"
    echo -e "\t-R,  setup Django REST Framework (Django only)"
    echo -e "\t-r,  setup ReactJS frontend (Django only)"
    echo -e "\t-t = time zone (Django only)"
    echo -e "\t-h,  show help"
    echo -e "\nSupported frameworks:"
    echo -e "\t- Flask"
    echo -e "\t- Django"
    echo -e "\t- PyQt5"
}

PYTHON_CMD="python3"
which $PYTHON_CMD >/dev/null 2>&1
if [[ "$?" -ne 0 ]]; then
    PYTHON_CMD="python"
fi

PIP_CMD="pip3"
which $PIP_CMD >/dev/null 2>&1
if [[ "$?" -ne 0 ]]; then
    PIP_CMD="pip"
fi

PROJ_NAME="myproject"
APP_NAME="myapp"
TIME_ZONE="EST"

while getopts "p:a:dRrt:h" flag; do
    case "$flag" in
        p)  PROJ_NAME=${OPTARG};;
        a)  APP_NAME=${OPTARG};;
        d)  SETUP_DATABASE="TRUE";;
        R)  SETUP_REST_API="TRUE";;
        r)  SETUP_REST_API="TRUE"
            SETUP_REACT="TRUE";;
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
    flask)          flask_boilerplate;;
    django)         django_boilerplate;;
    pyqt5)          pyqt5_boilerplate;;
    reactnative)    reactnative_boilerplate;;
    *)              print_usage;;
esac