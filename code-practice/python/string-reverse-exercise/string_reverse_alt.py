#! /usr/bin/env python

"""
try doing this without the "reverse()" function
"""

my_string = raw_input("Enter a string: ")

print("The original string is: ", my_string)

my_list = ''.join(my_string)

ctr = 1

for i in my_list:
    last_item = len(my_list)
    print (my_list[last_item - ctr])
    ctr = ctr+1
