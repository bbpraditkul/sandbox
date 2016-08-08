#!/usr/bin/python

__version__ = '0.1'
__author__ = 'bryan praditkul'

import time
import argparse

#==============================================
# The goal of the following script is to test the performance between pypy and std python
# Work in progress...
#

parser = argparse.ArgumentParser(description="Load up the system a bit to test pypy vs std python")

#=============================
#parser.add_argument('-v', '--version', action='version', version='%(prog)s version={version}'.format(version=__version__))
#  just another way to print version (using the format method, taking __version__ as an argument.

parser.add_argument('-v', '--version', action='version', version='%(prog)s version=' + __version__)

#=============================
#a few useful attributes to remember for argsparse
#  required=True  # require the arg
#  type=list, default=[] (pass the arg as: "1 2 3")  #pass a list
#  action='store_true', default=False, dest='boolean_switch'  #set True if present
#  action='store_false', default=True, dest='boolean_switch'  #set False if present
#
parser.add_argument('-s', '--seconds', action='store', dest='wait_seconds', default=5, help='seconds to run the generic load')

args = parser.parse_args()

#

#print (time.strftime("%m/%d/%Y - %H:%M:%S"))
#print (time.time())
