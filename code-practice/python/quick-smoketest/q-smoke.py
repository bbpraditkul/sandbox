#!/usr/bin/python

import requests
import re
import argparse
import random

smoketest_file = ''

parser = argparse.ArgumentParser(description="Simple Smoketest script")

parser.add_argument('-f', '--file', action='store', dest='smoketest_file', default='smoketests.txt', help='input file')

args = parser.parse_args()

def main():
    print ("Starting smoketest...")

    tests_list = parseInput()
    cookies = []

    for item in tests_list:
        (smoketest_name,test_url,operator,expected_response,cookies) = item.split(',')
        print ('\nProcessing: ' + smoketest_name)
        smoketest(test_url,operator,expected_response,cookies)

#=======================
# parseInput()
#Simple function to open the file and return a list
#
def parseInput():
    smoketests = []

    f_in = open(args.smoketest_file, 'r')

    for line in f_in.read().split('\n'):
        if not line.strip():
            pass
        elif re.search('^#',line):
            pass
        else:
            smoketests.append(line)
    f_in.close()
    return smoketests

#=======================
# smoketest()
#Simple function to match a response to the request
#
def smoketest(url,operator,expected_resp,cookies):
    operator = operator.lower()
    cookie = ''
    print ('  Testing: %s %s "%s"' % (url,operator,expected_resp))
    if cookies != '':
        print ('  Setting cookie to:' + cookies)
        cookie = {'RED': ''}
        http_resp = requests.get(url, cookies=cookie)
    else:
        http_resp = requests.get(url)

    if operator=='is' and expected_resp in http_resp.text:
        print ('  [ OK ]')
        print (str(http_resp.text))
    elif operator=='is not' and expected_resp not in http_resp.text:
        print ('  [ OK ]')
    else:
        print ('  [ FAILED ]')

if __name__ == '__main__':
    main()