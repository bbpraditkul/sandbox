#!/bin/env/env python

"""
The app.py file is the Python code that will import the app and execute.

The views.py file contains a view function.

The models.py file contains SQLAlchemy models.

The static folder contains all the css and javascript files.

The templates folder contains Jinja2 templates.

Install Postgres.app
export PATH=/Applications/Postgres.app/Contents/Versions/9.5/bin:"$PATH"
pip install psycopg2 Flask-SQLAlchemy

"""

from flask import Flask

app = Flask(__name__)

from views import *

if __name__ == '__main__':
    app.run()

