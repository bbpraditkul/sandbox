#!/usr/bin/env python3
'''
#the main class is known as the base class or the superclass
class Pet:

    def __init__(self, name, age):
        self.name = name
        self.age = age
#the class that inherits its methods from the base class is known as the subclass
class Cat(Pet):

    def __init__(self, name, age):
        super().__init__(name, age) # you can run super class methods like this


def Main():

    thePet = Pet('Pet', 1)
    jess = Cat('Jess', 3)

    print('is jess a cat?' + str(isinstance(jess, Cat)))
    print('is jess a pet?' + str(isinstance(jess, Pet)))
    print('is the pet a cat' + str(isinstance(thePet, Cat)))
    print('is the pet a Pet' + str(isinstance(thePet, Pet)))

    print(jess.name)

if __name__ == '__main__':
    Main()
'''

#Polymorphism: method in the base class that MUST be overridden by the subclass
#
class Pet:

    def __init__(self, name, age):
        self.name = name
        self.age = age

    #raises an error if the subclass doesn't define/invoke the talk method
    def talk(self):
        raise NotImplementedError('subclass must implement abstract method')

class Cat(Pet):

    def __init__(self, name, age):
        super().__init__(name, age) # you can run super class methods like this

    def talk(self):
        return "Meow"

class Dog(Pet):
    def __init__(self, name, age):
        super().__init__(name, age)

    def talk(self):
        return "Ruff"

def Main():

    pets = [Cat('jess', 3), Dog('jack', 2), Cat('Fred', 7), Pet('Pet', 5)]

    for i in pets:
        print("Name: " + i.name + " Age: " + str(i.age) + " Says: " + i.talk())

if __name__ == '__main__':
    Main()