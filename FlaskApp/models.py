#from __init__ import db
from app import db

class Users(db.Model):
    username = db.Column(db.String, primary_key=True)
    password = db.Column(db.String, nullable=False)
    def is_authenticated(self):
        return True

    def is_active(self):
        return True

    def is_anonymous(self):
        return False

    def get_id(self):
        return self.username

    def __init__(self, username, password, role):
        self.username = username
        self.password = password
        self.role = role
