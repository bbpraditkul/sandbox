WTF_CSRF_ENABLED = True #adds security on the site against "cross site request forgery"
SECRET_KEY = 'some-test-key' #needed for CSRF

OPENID_PROVIDERS = [
    {'name': 'Google', 'url': 'https://www.google.com/accounts/o8/id'},
    {'name': 'Yahoo', 'url': 'https://me.yahoo.com'}
]