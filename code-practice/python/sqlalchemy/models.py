from flask.ext.sqlalchemy import SQLAlchemy

app = Flask(__name__)
db = SQLAlchemy(app)

class TestTable (db.Model):
    __tablename__ = "testtable"
     id = db.Column('id', db.Integer, primary_key=True)
     name = db.Column('name', db.Unicode)
     value = db.Column('value', db.Integer)