#!/usr/bin/python

__version__ = '0.1'
__author__ = 'bryan praditkul'

import time
import argparse
import random

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
parser.add_argument('-n', '--numbers', action='store', dest='numbers', default=1, help='number of random integers to generate and store/destroy')
parser.add_argument('-t', '--type', action='store', dest='type', help='type of busy work')
args = parser.parse_args()

acceptable_types = ['disk', 'cpu', 'memory']

if args.type not in [acceptable_types]:
    print ("unknown type, exiting...")
    exit()

start_epoch = time.time()
current_epoch = start_epoch
end_epoch = start_epoch+int(args.wait_seconds)

print ('Start Time: ' + time.ctime(start_epoch))
print ('End Time: ' + time.ctime(end_epoch))

def busy_cpu_work():
    my_list = []
    for i in range(0,int(args.numbers)):
        my_list.append(random.randint(1,10))
    print (my_list)  #keep the CPU busy
    del my_list[:]

def busy_disk_work():
    my_list = []
    for i in range(0,int(args.numbers)):
        my_list.append(random.randint(1,10))
    fh = open('my_file', 'w')
    fh.write(''.join(str(v) for v in my_list))
    fh.close()

    #with open('my_file', 'r') as fh:
    #    print (fh.read())
    #fh.closed

    del my_list[:]

while (current_epoch < end_epoch):
    #time.sleep(2)
    if args.type == 'disk':
        busy_disk_work()
    elif args.type == 'cpu':
        busy_cpu_work()
#    elif args.type == 'memory':
        #busy_mem_work()
    else:
        None

    current_epoch = time.time()

    #print (my_list)



