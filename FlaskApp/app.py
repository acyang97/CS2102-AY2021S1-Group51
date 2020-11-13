#from __init__ import db, login_manager
#from views import view
#from models import Users

from FlaskApp import Users
from FlaskApp import view

from flask import Flask
from flask_login import UserMixin
#from flask_admin.contrib.sqla import ModelView
#from flask_admin import Admin

import os


from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager

db = SQLAlchemy()
login_manager = LoginManager()
login_manager.login_view = 'view.login' # must login to access the account route.
login_manager.login_message_category = 'info'


app = Flask(__name__)
#admin = Admin(app)
#admin.add_view(ModelView(Users, db.session))


# Routing
app.register_blueprint(view)

# Config
#    .format(
#app.config["SQLALCHEMY_DATABASE_URI"] = "postgresql://{username}:{password}@{host}:{port}/{database}"\
#        username="postgres",
#        password="S0hyun97!",
#        host="localhost",
#        port=5432,
#        database="flaskk"
#    )

app.config["SQLALCHEMY_DATABASE_URI"] = "postgres://ekelwriinaourw:2dcd9c0d5e5484916d65716d7d9d564906575e79cda625fa5e727a6ae36f61c9@ec2-3-211-176-230.compute-1.amazonaws.com:5432/dd7o7a5cfo2utd"

app.config["SECRET_KEY"] = "SECRET_KEY"
#port = int(os.environ.get("PORT", 5000))
# Initialize other components
db.init_app(app)
login_manager.init_app(app)


#if __name__ == "__main__":
#    app.run(
#        debug=True,
#        host="localhost",
#        #port=5000
#        port = int(os.environ.get("PORT", 5000))
#    )
port = int(os.environ.get('PORT', 33507))

if __name__ == "__main__":
    app.debug = True
    app.run(host='0.0.0.0', port=port)
