import random
import re
import sys
import os
from copy import deepcopy
import time

__author__ = 'bryanpraditkul'

"""The following code tests random class methods and features of Python.  While there's no rhyme or rhythm to the madness,
this is my sandbox to stretch my Python legs.  If someone sees this code and has advice on best practices, PLEASE share them
with me.  I'm more than open to 1) learning new practices, 2) testing out new ideas, and 3) generally cleaning up my code
"""

#testStrings() tests a few built-in string methods
#
def testStrings(my_str,my_str2):
    length = len(my_str)
    uppercase = my_str.upper()
    fifth_char = my_str[5]
    slice_op = my_str[5:10]
    found = my_str.find('test')

    out = []
    out.append("added " + my_str2)
    out.append("The string has " + str(length) + " characters, \n")
    out.append("the 5th character of '" + fifth_char + "'\n")
    out.append("a 5-10 char subtring of '" + slice_op + "'\n")
    if found:
        out.append("has the word 'test' in it" + "\n")
    out.append("and uppercased, looks like '" + uppercase + "'\n")

    return ''.join(out)



#testConditions() tests condition statements
#
def testConditions(my_str):
    if my_str.startswith("e"):
        return "It started with an 'e'"
    elif my_str.endswith("g"):
        return "It ended with a 'g'"
    else:
        return "It matched nada..."

#testLoopControls() tests loop controls
def testLoopControls():
    count = 0
    while (count <= 5):
        if (count == 3):
            pass #skip the iteration, but stays in the loop
        else:
            print count
        count += 1
    return "Count completed"

#testExits() tests simple system exits
#
def testExits():
    raise SystemExit("Uh Oh.  I exited for some reason.")

#testExceptionHandling() tests "try" blocks
def testExceptionHandling():
    try:
        x = 1/0
    except ZeroDivisionError:
        print "tried to divide by 0"

#testUserInput plays a bit with simple user input
def testUserInput():
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

#testFiles() plays a bit with files
def testFiles():
    filename = "sandboxdata.txt"
    #f = open(filename)
    #lines = f.readlines()
    for line in open(filename):
        #print line
        testParsing(line)

#testParsing() splits the lines with a whitespace as the delimiter
def testParsing(line):
    my_items = re.split(r'\s+', line)
    del my_items[0]
    print my_items
    #for item in my_items:
        #print "test", item

#testArgs(() tests basic argument input
def testArgs():
    if len(sys.argv) > 1:
        return sys.argv[1]
    else:
        return "No Arguments"

#testListsAndLoL() demonstrates a few nuances when performing normal copy ops with Lists vs LoLs
def testListsAndLOL():
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

#testDictionaries() tests basic init and return of dictionaries
def testDictionaries():
    myDict = {'b':'1', 'a':'2'}
    for key, value in sorted(myDict.items()):
        print key,value

#testHoL() demonstrates a few add/del methods available when dealing with HoLs
def testHoL():
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

#testRegexes() demonstrates how to do simple matches and a quick search/replace
def testRegexes():
    my_str = 'the cow jumps over the moon'
    #if re.match('jumps', my_str):
    if re.search('\S*\sover', my_str):
        print "found a match"
    else:
        print "no match"

    my_new_str = my_str.replace('jump', 'waddle')
    print my_new_str

def testEmailSearches():
    print "how many entries are there?"
    num_of_entries = raw_input()
    all_emails = {}
    counter = 0
    out = []
    while (counter < int(num_of_entries)):
        email = ""
        print "enter a line of text with an email embedded somewhere"
        my_str = raw_input()
        line_entry = re.findall("(\S+\@\w+\.[^\s]+)", my_str)
        if line_entry:
            for email_raw in line_entry:
                email = re.sub(r'\W$', "", email_raw)
        else:
            pass

        if email == "":     #gives a little insurance instead of doing something like "if not email" since None, 0, False would incorrectly get into this condition.
            pass
        else:
            #if we wanted to sort (regardless of capitalization,
            #for key in sorted(all_emails.keys(), key=lambda v: v.upper()):
            #    out.append(key)
            out.append(email)

        counter += 1

    return ';'.join(out)

#testPickling() demonstrates how to serialize and deserialize a list. The advantage of pickling is to turn the object into a stream of data that can be then sent over a network (eg for map-reduce, distributed computing scenarios, etc)
def testPickling():
    my_list = ['mocha','latte','dark coffee','americano']
    out_file = open('pickle.txt', 'wb')
    pickle.dump(my_list, out_file)
    out_file.close()
    print "Done creating pickle file"
    in_file = open('pickle.txt', 'rb')
    new_list = pickle.load(in_file)
    print new_list

#testSysCommands() demonstrates how to invoke system calls from the shell
def testSysCommands():
    os.system('env  '
              '| grep SHELL'
    )
    return

#testPassingArgs() demonstrates how to pass arguments between functions
def testPassingArgs():
    my_dictionary = {'b':'1', 'c':'2'}

    #"*" is typically used for a list (when the number of args isn't known), "**" is used for a dictionary
    def passItHere(**kwargs):
        for key,value in kwargs.items():
            print "%s => %s" % (key,value)

    passItHere(**my_dictionary)

def testMessageInput():
    num_of_lines = raw_input("How many lines are you putting in!")
    counter = 0
    my_list = []
    while (counter < int(num_of_lines)):
        counter += 1
        my_str = raw_input("Give it a go:")
        my_list.append(my_str)

    for j in my_list:
        if re.search('^foo$', j):
            print "Line ", j, ": why just foo?"
        elif re.search('bar$', j):
            print "Line ", j, ": ok, the end bar's in there"
        elif re.search('\S*foobar\S*', j):
            print "Line ", j, ": ok, now we're getting somewhere"
        else:
            print "don't give up!"

def testMoreRegexesAndLists():
    counter = 0
    num_of_entries = int(raw_input("How Many Lines?"))
    my_output = []

    while (counter < num_of_entries):
        my_list = []
        my_str = raw_input()
        m = re.search('(\d+).(\d+).(\d+)', my_str)
        if m:
            my_list.append("CountryCode=" + m.group(1))
            my_list.append("LocalAreaCode=" + m.group(2))
            my_list.append("Number=" + m.group(3))

        my_output.append('.'.join(my_list))
        counter += 1

    for line in my_output:
        print line

#testLambdas() is equivalent to doing something like:
# def somefunc(x):
#   return x+1
#lambdas are good for one-off functions that only get used once.
# a good reference with limitations:
# https://pythonconquerstheuniverse.wordpress.com/2011/08/29/lambda_tutorial/
#
def testLambdas():
    print "testing lambda x: x+1"
    f = (lambda x: x+1)
    print f(4)
    print "testing "
    s = (lambda x: " ".join(x) )
    print s('this is a test')

def testTime():
    print time.strftime("%H:%M:%S")
    print "%s" % time.localtime()
    s = time.strptime("12:00:00", "%H:%M:%S")
    print s