#!/usr/bin/python

import requests

smoketest_file = 'smoketests.txt'

def main():
    print ("Starting smoketest...")

    tests_list = parseInput()

    for item in tests_list:
        (smoketest_name,test_url,operator,expected_response) = item.split(',')
        print ('Processing: ' + smoketest_name)
        smoketest(test_url,operator,expected_response)

#=======================
# parseInput()
#Simple function to open the file and return a list
#
def parseInput():
    smoketests = []

    f_in = open(smoketest_file, 'r')

    for line in f_in.read().split('\n'):
        if not line.strip():
            pass
        else:
            smoketests.append(line)
    f_in.close()
    return smoketests

#=======================
# smoketest()
#Simple function to match a response to the request
#
def smoketest(url,operator,expected_resp):
    operator = operator.lower()
    print ('  Testing: %s %s "%s"' % (url,operator,expected_resp))
    http_resp = requests.get(url)

    if operator=='is' and expected_resp in http_resp.text:
        print ('  [ OK ]')
    elif operator=='is not' and expected_resp not in http_resp.text:
        print ('  [ OK ]')
    else:
        print ('  [ FAILED ]')

if __name__ == '__main__':
    main()