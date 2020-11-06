from flask import Flask
from flask_login import UserMixin
#from flask_admin.contrib.sqla import ModelView
#from flask_admin import Admin

from __init__ import db, login_manager
from views import view
from models import Users

import os

app = Flask(__name__)
#admin = Admin(app)
#admin.add_view(ModelView(Users, db.session))


# Routing
app.register_blueprint(view)

# Config
app.config["SQLALCHEMY_DATABASE_URI"] = "postgresql://{username}:{password}@{host}:{port}/{database}"\
    .format(
        username="postgres",
        password="S0hyun97!",
        host="localhost",
        port=5432,
        database="flaskk"
    )
app.config["SECRET_KEY"] = "SECRET_KEY"
#port = int(os.environ.get("PORT", 5000))
# Initialize other components
db.init_app(app)
login_manager.init_app(app)


if __name__ == "__main__":
    app.run(
        debug=True,
        host="localhost",
        #port=5000
        port = int(os.environ.get("PORT", 5000))
    )
