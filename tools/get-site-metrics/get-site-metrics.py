#!/usr/bin/env python

"""
Contents that would be mirrored in the README file (hackerrank doesn't seem to allow additional file attachments)
author: Bryan Praditkul
date: 20141130
description: The following script simply tests basic performance for a site's true page.
             It captures the following core stats - status code, response time, max/min/avg and redirect counts
Tested on: Python 2.7.5

Modules (built-in): argparse, re
Modules (need to install): requests

To install the "requests" module, execute:

    sudo pip install requests

usage: ./get-site-metrics.py [-h] [-v] -u URL [-t <timeout>]
   eg. ./get-site-metrics.py -u www.mint.com
"""
import requests
import argparse
import re

#=============================
# initialize a few quick variables
#
timeout  = 15
redirect = ''
response_time = 0
status_code   = 0
stats = {'count':0,
         'avg':0,
         'min_time_and_url':[timeout,''],
         'max_time_and_url':[0,'']
         }

#=============================
# parse the user's arguments with the argparse module
#
parser = argparse.ArgumentParser(description="Execute a basic performance test for a site's \"true\" page ")

parser.add_argument('-v',
                    dest='verbose',
                    action='store_true',
                    help='verbose mode')
parser.add_argument('-t',
                    dest='timeout',
                    action='store',
                    type=float,
                    help='timeout')
parser.add_argument('-u',
                    dest='url',
                    action='store',
                    help='HTTP or HTTP url',
                    required='True')
args = parser.parse_args()

url = args.url
verbose = args.verbose
if args.timeout:
    timeout = args.timeout

if verbose:
    print "[INFO] Timeout set to %s" % timeout

#=============================
# sanitizeURL() - while the requests module does extensive error checking, let's give the url a chance by
# resolving a few basic issues (eg. missing protocol, apex domains, etc)
#
def sanitizeURL(url):
    sanitized_url = url

    if verbose:
        print "[INFO] Sanitizing url if needed..."

    if re.search('^https?://\S+\.\S+\.\S+', url):
        None
    elif re.search('^\S+\.\S+\.\S+', url):
        sanitized_url = ''.join(('http://',url))
    elif re.search('^\S+\.\S+$',url):
        sanitized_url = ''.join(('http://www.',url))

    return sanitized_url

#=============================
# updateAvg() - take 2 numbers and return the avg
#
def updateAvg(url_time,avg):
    if verbose:
        print "[INFO] Adding %f to current avg %f" % (url_time, avg)

    if avg > 0:
        new_avg = (url_time + avg)/2
    else:
        new_avg = url_time

    return new_avg

#=============================
# checkMax() - return the higher of 2 numbers
#
def checkMax(max_time,max_url,new_url,new_time):
    if verbose:
        print "[INFO] Testing %f against current max time %f" % (new_time, max_time)

    if new_time > max_time:
        max_time = new_time
        max_url  = new_url
        if verbose:
            print "[INFO] Found new max time"
    else:
        None

    return (max_time,max_url)

#=============================
# checkMin() - return the lower of 2 numbers
#
def checkMin(min_time,min_url,new_url,new_time):
    if verbose:
        print "[INFO] Testing %f against current min time %f" % (new_time, min_time)

    if new_time < min_time:
        min_time = new_time
        min_url  = new_url
        if verbose:
            print "[INFO] Found new min time"
    else:
        None

    return (min_time,min_url)

#=============================
# requestURL() - Leverage the requests module (more control over redirects) to make the HTTP request.
# We set a few basic headers as well (no cache, and fake a User Agent). Here we'll take advantage of
# just a few of the request module's extensive exception
#
def requestURL(url):
    if verbose:
        print "[INFO] Trying URL %s" % url
    try:
        headers = {'Cache Control':'no-cache',
                   'User-Agent':'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:33.0) Gecko/20100101 Firefox/33.0'}
        response = requests.get(url, headers=headers, allow_redirects=False, timeout=timeout)
        status_code = response.status_code
        response_time = response.elapsed.total_seconds()
        redirect = response.headers.get('location')
        return redirect, response_time, status_code
    except requests.exceptions.Timeout:
        print "[ERROR] Request timed out\n"
    except requests.exceptions.ConnectionError:
        print "[ERROR] Unable to make the call to %s\n" \
              "        Check the the URL and or connection\n" % url
    except requests.exceptions.HTTPError:
        print "[ERROR] An unknown HTTP error was encountered\n"
    except requests.exceptions.RequestException as e:
        print "[ERROR] Something catastrophic happened\n"
        print e



#=============================
# printFormattedLine() - an easier way to print the contents of a list
#
def printFormattedLine(list_of_vals):
    for val in list_of_vals:
        if type(val) == int:
            print "%-20d" % val,
        elif type(val) == float:
            print "%-20.3f" % val,
        else:
            print "%-20s" % val,
    print

if __name__ == "__main__":

    print "="*30
    print "DETAILS"
    print "="*30
    printFormattedLine(['STATUS CODE','RESPONSE TIME(secs)','URL'])

    url = sanitizeURL(url)

    try:
        while status_code is not 200:
            (redirect, response_time, status_code) = requestURL(url)

            printFormattedLine([status_code, response_time, url])

            stats['count']+=1
            stats['avg'] = updateAvg(response_time,stats['avg'])
            stats['max_time_and_url'] = checkMax(stats['max_time_and_url'][0],stats['max_time_and_url'][1],url,response_time)
            stats['min_time_and_url'] = checkMin(stats['min_time_and_url'][0],stats['min_time_and_url'][1],url,response_time)

            url = redirect

        print
        print "="*30
        print "SUMMARY"
        print "="*30
        print "%-30s %d" % ("NUMBER OF URLS VISITED",stats['count'])
        print "%-30s %0.3fs" % ("AVERAGE REQUEST TIME",stats['avg'])
        print "%-30s %0.3fs" % ("LONGEST RESPONSE TIME",stats['max_time_and_url'][0])
        print "%-30s %s" % ("LONGEST RESPONSE URL",stats['max_time_and_url'][1])
        print "%-30s %0.3fs" % ("SHORTEST RESPONSE TIME",stats['min_time_and_url'][0])
        print "%-30s %s" % ("SHORTEST RESPONSE URL",stats['min_time_and_url'][1])
    except:
        pass #just exit as exceptions are already caught in requests module
