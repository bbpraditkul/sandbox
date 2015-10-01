#!/usr/bin/env python
import random

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










#Time to invoke our functions...
#
if __name__ == "__main__":
    main()



