from flask import Flask
#creates the application object of class Flask
#

#app_var used here is the name of the variable that's being assigned of the Flask class
app_var = Flask(__name__)

#app used here is the package where we're importing the "views" module
from app import views

