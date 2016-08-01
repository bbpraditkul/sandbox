#!/usr/bin/env python

"""
The following hack takes two files and compares the keys between the files.

This was designed and used to compare two token files...to show which keys were missing in each

usage:
   ./compare_keys.py <file1> <file2>
"""

import re
import sys

file1 = sys.argv[1]
file2 = sys.argv[2]

file1_dict={}
file2_dict={}

def parseFile(in_file):
  all_keys = {}

  for line in open(in_file):
     line = re.sub('\n','',line)
     config = re.split('=', line)

     if not config[0] or config[0].startswith('#'):
         None
     else:
         all_keys[config[0]]=config[1]

  return all_keys

file1_dict = parseFile(file1)
file2_dict = parseFile(file2)

print "comparing: " + file1 + " and " + file2

print file1 + " is not in " + file2
for file1_key,file1_value in (file1_dict.items()):
  if file1_key not in file2_dict.keys():
     print file1_key

print file2 + " is not in " + file1
for file2_key,file2_value in (file2_dict.items()):
  if file2_key not in file1_dict.keys():
     print file2_key


