from __init__ import db, login_manager
from views import view
from models import Users
#
from flask import Flask
from flask_login import UserMixin
#from flask_admin.contrib.sqla import ModelView
#from flask_admin import Admin

import os

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

app.config["SQLALCHEMY_DATABASE_URI"] = "postgres://geqxkvcbsuuwun:f4e765364abd812812aa44e295025c6fe1913472052afd38fd31fd1bfbbd0680@ec2-3-228-114-251.compute-1.amazonaws.com:5432/dde6dck5qd281f"

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
