function flask_boilerplate() {
    secret_key=`openssl rand -base64 12`
    
    cat > app.py <<EOF
from flask import Flask, render_template
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.secret_key = "$secret_key"
app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///users.sqlite3"
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
db = SQLAlchemy(app)

class User(db.Model):
    id = db.Column("id", db.Integer, primary_key = True)
    name = db.Column(db.String(150))

    def __init__(self, name):
        self.name = name

@app.route("/")
def home():
    return render_template("home.html")

if __name__ == "__main__":
    db.create_all()
    app.run()
EOF

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

APP=$1
if [ -z $APP ]; then
    echo usage
fi
APP=${APP,,}

case "$APP" in
    flask)  flask_boilerplate;;
    *)      echo usage;;
esac