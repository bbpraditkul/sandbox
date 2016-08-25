#!/usr/bin/python

"""
the following is just a testbed for playing with regexes
"""

import re

__author__ = 'bryan praditkul'
__version__ = '0.01' #it's not likely to change :-P

my_list = []
my_string = 'some garbled mess foo foo foo, bar bar bar, 20:15, *&^%$'

print('the string starts off as' + my_string)

#search for something in the string
if re.search('^some', my_string):
    print ('found a match')
else:
    print ('not in here')

#let's test out regex grouping in python
m = re.search('(\d+):(\d+)', my_string)

if m:
    my_list.append('new foo & ' + m.group(1) + ' ' +  m.group(2))
    print (my_list)
else:
    print ('that failed miserably')
