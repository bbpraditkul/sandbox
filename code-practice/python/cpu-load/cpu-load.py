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
# A few initial numbers:
#   ./cpu-load.py -t ops -o <ops> -b cpu
#  Ops          Python3      Pypy
#  10000000     22secs       1sec
#  1000000000   2641secs     86secs
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
parser.add_argument('-b', '--busyness', action='store', dest='busyness', default='cpu', help='type of busy work')
parser.add_argument('-t', '--type', action='store', dest='type', default='ops', help='type of load')
parser.add_argument('-o', '--ops', action='store', dest='ops', help='number of operations')

args = parser.parse_args()

acceptable_busyness = ['', 'disk', 'cpu', 'memory']
acceptable_types = ['time','ops']

if args.type not in acceptable_types:
    print ("unknown type, exiting...")
    print ("acceptable options: " + ','.join(acceptable_types))
    exit()

if args.busyness not in acceptable_busyness:
    print ("unknown busyness, exiting...")
    print ("acceptable options: " + ','.join(acceptable_busyness))
    exit()

def main():
    if args.type == 'time':
        time_based_load()
    elif args.type == 'ops':
        ops_based_load(int(args.ops))

def busy_cpu_work():
    my_list = []
    for i in range(0,int(args.numbers)):
        my_list.append(random.randint(1,10))
    #print (my_list)  #keep the CPU busy
    del my_list[:]
    return

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
    return

def ops_based_load(ops):
    start_epoch = time.time()
    for i in range(0,ops):
        if args.busyness == 'disk':
            busy_disk_work()
        elif args.busyness == 'cpu':
            busy_cpu_work()
        #elif args.busyness == 'memory':
            #busy_mem_work()
        else:
            None
    end_epoch = time.time()
    print ("Test completed in: " + str(int(end_epoch)-int(start_epoch)) + "seconds\n")
    return

def time_based_load():
    start_epoch = time.time()
    current_epoch = start_epoch
    end_epoch = start_epoch+int(args.wait_seconds)

    print ('Start Time: ' + time.ctime(start_epoch))
    print ('End Time: ' + time.ctime(end_epoch))

    while (current_epoch < end_epoch):
        #time.sleep(2)

        if args.busyness == 'disk':
            busy_disk_work()
        elif args.busyness == 'cpu':
            busy_cpu_work()
        #elif args.busyness == 'memory':
            #busy_mem_work()
        else:
            None

        current_epoch = time.time()
    return

if __name__ == "__main__":
    main()