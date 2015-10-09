#!/usr/bin/env python

import random
import re
import sys
import os
from copy import deepcopy
from time import sleep
import practicemodule as practice

__author__ = 'BryanPraditkul'

"""The following code drives the random class methods and features leveraged in practicemodule.py.  While there's no rhyme or rhythm to the madness,
this is my sandbox to stretch my Python legs.  If someone sees this code and has advice on best practices, PLEASE share them
with me.  I'm more than open to 1) learning new practices, 2) testing out new ideas, and 3) generally cleaning up my code
"""

my_str = 'This is a test string'

#Let's insure that we don't invoke the functions if the module isn't explicitly executed.
#
def main():

    d = {   '1': [practice.testStrings,[my_str,"t1"]],
            '2': [practice.testConditions,[my_str]],
            '3': [practice.testLoopControls,[]],
            '4': [practice.testExits,[]],
            '5': [practice.testExceptionHandling,[]],
            '6': [practice.testUserInput,[]],
            '7': [practice.testFiles,[]],
            '8': [practice.testArgs,[]],
            '9': [practice.testListsAndLOL,[]],
            '10': [practice.testDictionaries,[]],
            '11': [practice.testHoL,[]],
            '12': [practice.testRegexes,[]],
            '13': [practice.testEmailSearches,[]],
            '14': [practice.testPickling,[]],
            '15': [practice.testSysCommands,[]],
            '16': [practice.testPassingArgs,[]],
            '17': [practice.testMessageInput,[]],
            '18': [practice.testMoreRegexesAndLists,[]],
            '19': [practice.testLambdas,[]],
            '20': [practice.testTime,[]]
        }

    selected = ""

    while not re.search('[Qq]', selected):
        for key in sorted(d.keys(), key=lambda x: float(x)):
            print key, ": ", d[key][0].__name__   #print the function name attribute

        selected = raw_input("Enter an option: ")

        if d.has_key(selected):
            my_args = d[selected][1]
            print d[selected][0](*my_args)  # pass the list as arguments
            sleep(5)
        else:
            print "[Error] Not a valid option, try again"
            sleep(1)

#Time to invoke our functions...
#
if __name__ == "__main__":
    main()



