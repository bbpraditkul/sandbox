from flask_sqlalchemy import SQLAlchemy
from app import app

"""
run in ipython:
>>> from app import app
>>> from models import db
>>> db.create_all()

"""


db = SQLAlchemy(app)

class TestTable (db.Model):
    __tablename__ = "testtable"
    id = db.Column('id', db.Integer, primary_key=True)
    name = db.Column('name', db.Unicode)
    value = db.Column('value', db.Integer)