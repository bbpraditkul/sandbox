#!flask/bin/python

#imports the app variable from our app package and invokes the "run" method
from app import app_var

app_var.run(debug=True)
