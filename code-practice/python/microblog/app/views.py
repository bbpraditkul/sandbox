from app import app_var
from flask import render_template #templates

#simple view function

#the "route" decorators simply map the paths to the function

@app_var.route('/')
@app_var.route('/index')

#basic "hello world" example
#def index():
#    return "This is a test page..."
#

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
