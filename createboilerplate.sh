# ----------------------------------------------------------------------
# Django Boilerplate Script
# ----------------------------------------------------------------------
# Options:
# -p = project name
# ----------------------------------------------------------------------
# Requirements:
# - Python3
# - Django
# - Django Rest Framework
# - Django CORS Headers
# ----------------------------------------------------------------------

django_boilerplate() {
    # Check for django, djangorestframework, django-cors-headers installation
    echo -e "Verifying requirements..."
    FREEZE=`${PIP_CMD} freeze 2>&1`
    django_installation=`echo "$FREEZE" | grep -E "Django==[\d.]*"`
    djangorestframework_installation=`echo "$FREEZE" | grep -E "djangorestframework==[\d.]*"`
    djangocorsheaders_installation=`echo "$FREEZE" | grep -E "django-cors-headers==[\d.]*"`

    if [ -z "${django_installation}" ] || [ -z "${djangorestframework_installation}" ] || [ -z "${djangocorsheaders_installation}" ]; then
        echo -e "Error: Requirements not installed"
        echo -e "Please install requirements by running \"pip3 install django djangorestframework django-cors-headers\""
        exit 127
    fi

    # Create project
    echo -e "Creating Django project \"${PROJ_NAME}\"..."
    django-admin startproject --template ${SCRIPT_DIR}/templates/Django/project_template ${PROJ_NAME}

    # Create app
    echo -e "Creating Django app \"accounts\"..."
    cd ${PROJ_NAME}
    django-admin startapp --template ${SCRIPT_DIR}/templates/Django/accounts_app_template accounts

    echo -e "Finished creating boilerplate Django project!"
}

# ----------------------------------------------------------------------
# Flask Boilerplate Script
# ----------------------------------------------------------------------
# Options:
# -p = project name
# ----------------------------------------------------------------------
# Requirements:
# - Python3
# - Flask
# - Flask SQLAlchemy
# ----------------------------------------------------------------------

flask_boilerplate() {
    # Check for flask and flasksqlalchemy installation
    echo -e "Verifying requirements..."
    FREEZE=`${PIP_CMD} freeze 2>&1`
    flask_installation=`echo "${FREEZE}" | grep -E "Flask==[\d.]*"`
    flasksqlalchemy_installation=`echo "${FREEZE}" | grep -E "Flask-SQLAlchemy==[\d.]*"`

    if [ -z "${flask_installation}" ] || [ -z "${flasksqlalchemy_installation}" ]; then
        echo -e "Warning: Requirements not installed"
        echo -e "Please install requirements by running \"pip3 install Flask Flask-SQLAlchemy\""
    fi

    mkdir -p ${PROJ_NAME}
    cp -r ${SCRIPT_DIR}/templates/Flask/* ${PROJ_NAME}
    mv ${PROJ_NAME}/app.py ${PROJ_NAME}/${PROJ_NAME}.py

    echo -e "Finished creating boilerplate Flask project!"
}

# ----------------------------------------------------------------------
# Go Website Boilerplate Script
# ----------------------------------------------------------------------
# Options:
# -p = project name
# -u = github username
# ----------------------------------------------------------------------
# Requirements:
# - Go
# ----------------------------------------------------------------------

go_boilerplate() {
    # Check for Go installation
    echo -e "Verifying requirements..."
    which go >/dev/null 2>&1
    if [[ "$?" -ne 0 ]]; then
        echo -e "Warning: Go not installed"
        echo -e "Please install Go from https://go.dev/"
    fi

    mkdir -p ${PROJ_NAME}
    cp -r ${SCRIPT_DIR}/templates/Go/* ${PROJ_NAME}
    cd ${PROJ_NAME}
    go mod init github.com/${GITHUB_USERNAME}/${PROJ_NAME}
    find . -type f -name "*.go" -print0 | xargs -0 sed -i '' "s/{{[[:space:]]*github_username[[:space:]]*}}/${GITHUB_USERNAME}/g"
    find . -type f -name "*.go" -print0 | xargs -0 sed -i '' "s/{{[[:space:]]*project_name[[:space:]]*}}/${PROJ_NAME}/g"

    echo -e "Finished creating boilerplate Go web project!"
}

# ----------------------------------------------------------------------
# PyQt6 Boilerplate Script
# ----------------------------------------------------------------------
# Options:
# -p = project name
# ----------------------------------------------------------------------
# Requirements:
# - Python3
# - PyQt6
# ----------------------------------------------------------------------

pyqt6_boilerplate() {
    # Check for pyqt6 installation
    echo -e "Verifying requirements..."
    FREEZE=`${PIP_CMD} freeze 2>&1`
    pyqt6_installation=`echo "${FREEZE}" | grep -E "PyQt6==[\d.]*"`

    if [ -z "${pyqt6_installation}" ]; then
        echo -e "Warning: Requirements not installed"
        echo -e "Please install requirements by running \"pip3 install PyQt6\""
    fi

    mkdir -p ${PROJ_NAME}
    cp -r ${SCRIPT_DIR}/templates/PyQt6/* ${PROJ_NAME}
    mv ${PROJ_NAME}/app.py ${PROJ_NAME}/${PROJ_NAME}.py

    echo -e "Finished creating boilerplate PyQt6 project!"
}


print_usage() {
    echo -e "\nUsage:"
    echo -e "\tcreateboilerplate.sh [OPTIONS] <framework_name>"
    echo -e "\nOptions:"
    echo -e "\t-p = project name"
    echo -e "\t-u = github username (Go only)"
    echo -e "\t-h,  show help"
    echo -e "\nSupported frameworks:"
    echo -e "\t- django"
    echo -e "\t- go"
    echo -e "\t- flask"
    echo -e "\t- pyqt6"
}

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJ_NAME="myproject"
GITHUB_USERNAME="myusername"

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

while getopts "p:u:d" flag; do
    case "$flag" in
        p)  PROJ_NAME=${OPTARG};;
        u)  GITHUB_USERNAME=${OPTARG};;
        h)  print_usage
            exit 0;;
        *)  exit 128;;
    esac
done

FRAMEWORK=${@:$OPTIND:1}
if [ -z $FRAMEWORK ]; then
    print_usage
    exit 128
fi
FRAMEWORK=${FRAMEWORK,,}

case "$FRAMEWORK" in
    django)         django_boilerplate;;
    flask)          flask_boilerplate;;
    go)             go_boilerplate;;
    pyqt6)          pyqt6_boilerplate;;
    *)              print_usage;;
esac
