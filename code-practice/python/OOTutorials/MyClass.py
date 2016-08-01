#!/usr/bin/env python3

class MyClass:
    name = "noname"
    number = 1234
    fav_letters = []

def main():
    me = MyClass()
    me.name = "bryan"
    me.number = "3456"
    me.fav_letters = ['a','b']

    you = MyClass()
    you.name = "someone"
    you.number = "0000"

    empty = MyClass()

    print('Name: ' + me.name + ' Number: ' + str(me.number) + ' Fav Letters ')
    for i in me.fav_letters:
        print(i)
    print('Name: ' + you.name + ' Number: ' + str(you.number))
    print('Name: ' + empty.name + ' Number: ' + str(empty.number))

if __name__ == '__main__':
    main()