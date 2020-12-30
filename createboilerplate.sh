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

while getopts "d" flag; do
    case "$flag" in
        d) SETUP_DATABASE="TRUE";;
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
    *)      echo usage;;
esac