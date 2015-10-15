#!/usr/bin/env python
import re
import sys

#The following is one solution to a typical interview question that I like to ask:
#Question:
#Write a program that reverses strings in a file, line by line, from top to bottom
#For example, given a file that has:
#  abc def
#  12 23 34
#  foobar
#The script would return:
#  fed cba
#  43 32 21
#  raboof
#

arr1 = []

if len(sys.argv) > 1:
    for line in open(sys.argv[1]):
        m = re.search('^(.+)$', line)
        if m:
            print 'original', m.group(1)
            list1 = list(m.group(1))
            list1.reverse()
            print 'reversed:', ''.join(list1)
        else:
            pass
else:
    print "usage: string_reverse.py <filename.txt>"

