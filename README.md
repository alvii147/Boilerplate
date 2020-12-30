# Boilerplate code generator

`createboilerplate.sh` is a bash script for generating boilerplate code for basic libraries and frameworks.

## Setting up an alias

It's convenient to set up an alias for the path to this script so it can be called from anywhere.

```
alias createboilerplate="/e/Programming/Boilerplate/./createboilerplate.sh"
```

## Flask

```
createboilerplate [OPTIONS] flask
```

This creates a boilerplate Python [Flask](https://flask.palletsprojects.com/en/1.1.x/) application, with an HTML template, a CSS stylesheet, and an SQLite3 database.

![Flask App Tree Structure](img/flask_tree.PNG)

Executing `app.py` runs the basic Flask application on `localhost:5000`.

```
python3 app.py
```

![localhost:5000](img/flask_screenshot.PNG)

Note: [Flask](https://pypi.org/project/Flask/) and [Flask-SQLAlchemy](https://pypi.org/project/Flask-SQLAlchemy/) must be installed.

### Options
```
-d, setup database
```
## PyQt5

```
createboilerplate pyqt5
```

This creates a boilerplate PyQt5 script, `pyqt5app.py`. Running it starts a basic PyQt5 application.

```
python3 pyqt5app.py
```

![PyQt5 application](img/pyqt5_screenshot.PNG)

Note: [PyQt5](https://pypi.org/project/PyQt5/) must be installed/