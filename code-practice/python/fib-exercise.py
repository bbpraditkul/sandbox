#!/usr/bin/env python

"""
The following was an interview question that I embarrassingly couldn't answer 100%.
The question was to write a simple function that optimally prints the fibonacci number at the x position
1,1,2,3,5,8,13,21...
f(5) = 5
f(6) = 8
...
I've gotta prove I can do it :)
"""

element = 4

def getFib(n):
    start,curr = 1,1

    for i in range(n-1):
        tmp = start + curr
        start = curr
        curr = tmp

    return start

#
# And the way we all learned it in college was to leverage recursion
#
def getFibRec(n):
    if n==1:
        return 1
    elif n==2:
        return 1
    else:
        return getFibRec(n-1)+getFibRec(n-2)

print "Standard loop: ", getFib(element)
print "With recursion: ", getFibRec(element)


