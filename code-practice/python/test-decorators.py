#!/usr/bin/env python

import time
import urllib2

"""
instead of:
def download_webpage():
    url = 'http://www.yahoo.com/index.html'
    response = urllib2.urlopen(url, timeout = 60)
    return response.read()

def elapsed_time():
    t0 = time.time()
    webpage = download_webpage()
    t1 = time.time()
    print "Elapsed time: %s\n" % (t1-t0)

use a decorator so we can capture timing on any function
"""

def elapsed_time(function_to_time):
    def wrapper():
        t0 = time.time()
        function_to_time()
        t1 = time.time()
        print "Elapsed Time: %s\n" % (t1-t0)
    return wrapper

@elapsed_time
def download_webpage():
    url = 'http://www.yahoo.com/index.html'
    response = urllib2.urlopen(url, timeout = 60)
    return response.read()

@elapsed_time
def random_function():
    print "something else"
    for i in range(1,10000000):
        pass

webpage = download_webpage()

someotherfunction = random_function()