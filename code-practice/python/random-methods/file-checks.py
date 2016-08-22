#!/usr/bin/python

"""
The following script was just something I had to make sure I can do from memory

Question: Check that a file exists.  If it is, write something to it.
"""

import argparse
import os.path

parser = argparse.ArgumentParser(description='check of my memory with file handling')
parser.add_argument('-f','--file',action='store',help='a file goes here',default='file.txt',dest='filename')
args = parser.parse_args()

filename = args.filename

print ('Check if file: "' + args.filename + '" exists')

#Here is the tricky part...os.path.exists() is not correct as it will return True on a directory too!
#In this case, we definitely want os.path.isfile()

#Method 1: simply using the isfile function of the os module
#
if os.path.isfile(filename):
    print ('file exists')
    fh = open(filename, 'w')
    fh.write('foo')
else:
    print ('no file exists')

#Method 2: using a try/except block to achieve the same result.  Personally, the first method seems safer.
#
try:
    fh = open(filename)
    print ('file exists')
    fh = open(filename, 'w')
    fh.write('foo')
except (IOError,OSError) as e:
    print ('no file exists')
