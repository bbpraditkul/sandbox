#!/usr/bin/env python
import random
import re
import sys
from copy import deepcopy

__author__ = 'BryanPraditkul'

"""The following code tests random class methods and features of Python.  While there's no rhyme or rhythm to the madness,
this is my sandbox to stretch my Python legs.  If someone sees this code and has advice on best practices, PLEASE share them
with me.  I'm more than open to 1) learning new practices, 2) testing out new ideas, and 3) generally cleaning up my code
"""

my_str = 'This is a test string'

#Let's insure that we don't invoke the functions if the module isn't explicitly executed.
#
def main():
    print "[testingStrings]", testingStrings(my_str)
    print "[testingConditions]", testingConditions(my_str)
    print "[testingLoopControls]", testingLoopControls()
    #print "[testingExits]", testingExits()
    #print "[testingExceptionHandling]", testingExceptionHandling()
    print "[testingUserInput]", testingUserInput()
    print "[testingFiles]", testingFiles()
    print "[testingArgs]", testingArgs()
    print "[testingListsAndLOL]", testingListsAndLOL()
    print "[testingHoL]", testingHoL()

#testingStrings() tests a few built-in string methods
#
def testingStrings(my_str):
    length = len(my_str)
    uppercase = my_str.upper()
    fifth_char = my_str[5]
    slice_op = my_str[5:10]
    found = my_str.find('test')

    out = []
    out.append("The string has " + str(length) + " characters, \n")
    out.append("the 5th character of '" + fifth_char + "'\n")
    out.append("a 5-10 char subtring of '" + slice_op + "'\n")
    if found:
        out.append("has the word 'test' in it" + "\n")
    out.append("and uppercased, looks like '" + uppercase + "'\n")

    return ''.join(out)

#testingConditions() tests condition statements
#
def testingConditions(my_str):
    if my_str.startswith("e"):
        return "It started with an 'e'"
    elif my_str.endswith("g"):
        return "It ended with a 'g'"
    else:
        return "It matched nada..."

#testingLoopControls() tests loop controls
def testingLoopControls():
    count = 0
    while (count <= 5):
        if (count == 3):
            pass #skip the iteration, but stays in the loop
        else:
            print count
        count += 1
    return "Count completed"

#testingExits() tests simple system exits
#
def testingExits():
    raise SystemExit("Uh Oh.  I exited for some reason.")

#testingExceptionHandling() tests "try" blocks
def testingExceptionHandling():
    try:
        x = 1/0
    except ZeroDivisionError:
        print "tried to divide by 0"

#testingUserInput plays a bit with simple user input
def testingUserInput():
    random_number = random.randint(1,1000)
    try:
        some_input = raw_input("Give me a number...")
        print some_input, " is what you typed"
        print "That input as an integer would be:", int(some_input)
        print "As a divisor for a random number", random_number, ", that's", random_number/int(some_input)
    except ValueError:
        print "you needed an integer"
    except ZeroDivisionError:
        print "don't enter 0"
    finally:
        print "getting the last word in :)"

#testingFiles() plays a bit with files
def testingFiles():
    filename = "sandboxdata.txt"
    #f = open(filename)
    #lines = f.readlines()
    for line in open(filename):
        #print line
        testingParsing(line)

#testingParsing() splits the lines with a whitespace as the delimiter
def testingParsing(line):
    my_items = re.split(r'\s+', line)
    del my_items[0]
    print my_items
    #for item in my_items:
        #print "test", item

#testingArgs(() tests basic argument input
def testingArgs():
    if len(sys.argv) > 1:
        return sys.argv[1]
    else:
        return "No Arguments"

#testingListsAndLoL() demonstrates a few nuances when performing normal copy ops with Lists vs LoLs
def testingListsAndLOL():
    simpleList = ["cow", "bear", "dog"]
    LoL = [["a", "b", "c"],
           ["d", "e", "f"]]

    copiedList = list(simpleList)
    copiedList[2] = "chicken"
    print simpleList
    print copiedList

    for i in LoL:
        print i[0]  #first element of each sub list
    print LoL[0][1] #2nd element of the first list
    #LoL2 = copy(LoL)   #shallow copies the entire list
    #LoL2 = list(LoL)   #doesn't work for LoL
    #LoL2 = LoL[:]  #performs a slice which results in a reference to the list
    LoL2 = deepcopy(LoL)    #for LoL, deepcopies work to copy the contents in the nested list elements
    LoL2[0][1] = "z"
    print LoL
    print LoL2

#testingHoL() demonstrates a few add/del methods available when dealing with HoLs
def testingHoL():
    HoL = { 'a': ['a-1','a-2'],
            'b': ['b-3','b-4'],
            'c': ['c-5','c-6'] }
    #return HoL

    HoL['d'] = ['d-7','d-8']

    if 'c' in HoL:
        del HoL['c']
        #pop() would also work, but be careful as it'll raise a KeyError if the key doesn't exist

    for i in sorted(HoL.values()):
        print i[0]

    if HoL.has_key('b'):
        print "has the key 'b'"
    else:
        print "missing the 'b' key"



#Time to invoke our functions...
#
if __name__ == "__main__":
    main()



