
__author__ = 'bryanpraditkul'

def questionsGeneral():
    #Problem: remove whitespaces from the string below
    s = 'aaa bbb ccc ddd eee'
    #Solution 1:
    print ''.join(s.split())
    #Solution 2:
    print filter(lambda x: x != ' ',s)

    #Problem: Write a program to sort the following integers in list:
    nums = [1,5,2,10,3,45,23,1,4,7,9]
    #Solution:
    print sorted(nums)

    #Problem: Iterate over a list of words and use a dictionary to keep track of the frequency(count) of each word.
    #For example {'one':2, 'two':2, 'three':2}
    a='1,3,2,4,5,3,2,1,4,3,2'.split(',')
    #or
    #a=['1','3','2','4',...]
    my_dict = {}
    for i in a:
        try:
            my_dict[i] += 1
        except KeyError:
            my_dict[i] = 1

    print my_dict

