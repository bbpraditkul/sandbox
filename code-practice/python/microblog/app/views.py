from app import app_var
from flask import render_template, flash, redirect #templates: render_template, forms: flash,redirect
from .forms import LoginForm

#simple view function

#the "route" decorators simply map the paths to the function

@app_var.route('/')
@app_var.route('/index')
@app_var.route('/login', methods=['GET', 'POST'])
#basic "hello world" example
#def index():
#    return "This is a test page..."
#

def login():
    form = LoginForm()
    if form.validate_on_submit():
        flash('Login requested for OpenID="%s", remember_me=%s' %
              (form.openid.data, str(form.remember_me.data)))
        return redirect('/index')
    return render_template('login.html',
                           title='Sign In',
                           form=form,
                           providers=app_var.config['OPENID_PROVIDERS'])

#working with templates
def index():
    user = {'nickname': 'Bryan'}
    posts = [
        {
            'commenter': {'nickname': 'FakeUser1'},
            'body': 'Foofoo barbar in SF'
        },
        {
            'commenter': {'nickname': 'FakeUser2'},
            'body': 'Barbar foofoo in SC'
        }
    ]

    return render_template('index.html',
                           title='Test Home Page',
                           user=user,
                           posts=posts)
