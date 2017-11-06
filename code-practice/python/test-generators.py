#!/usr/bin/env python

def counter():
    i = 0
    while True:
        i+=1
#        return i   #standard function
        yield i     #turns this function into a generator which keeps state

a = counter()
#print a, type(a)   #standard function
                    #type is int

print next(a), type(a)  #'next' prints the next iteration
print next(a), type(a)  #type is generator
print next(a), type(a)
print next(a), type(a)
