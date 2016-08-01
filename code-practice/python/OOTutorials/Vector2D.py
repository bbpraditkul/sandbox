#!/usr/bin/env python3
'''
The code below does the equivalent of as __init__ is internal:

class Vector2D:
    x = 0.0
    y = 0.0
    def Set(self, x, y):
        self.x = x
        self.y = y

def main():
    vec = Vector2D()
    vec.Set(5,6)
    print('x: '+ str(vec.x) + ' y: ' + str(vec.y))

if __name__ == '__main__':
    main()

==============

class Vector2D:
    def __init__(self, x, y):
        self.x = x
        self.y = y

def main():
    vec = Vector2D(5,6)
    print ('x: ' + str(vec.x) + ' y: ' + str(vec.y))

if __name__ == '__main__':
    main()
================
#using numeric methods...they override the existing + - / * operators
import math
class Vector2D:
    def __init__(self, x, y):
        self.x = x
        self.y = y

    def __add__(self, other):
        return Vector2D(self.x + other.x, self.y + other.y)

    def __iadd__(self, other):
        self.x += other.x
        self.y += other.y
        return self

    def __sub__(self, other):
        return Vector2D(self.x - other.x, self.y - other.y)

    def __mul__(self, other):
        return Vector2D(self.x * other.x, self.y * other.y)

    def __truediv__(self, other):
        return Vector2D(self.x / other.x, self.y / other.y)

    def getLength(self):
        return math.sqrt(self.x**2 + self.y**2)

    def normalized(self):
        length = self.getLength()
        if length != 0:
            return Vector2D(self.x/length, self.y/length)
        return Vector2D(self)

    def __str__(self):
        return "X: " + str(self.x) + ", Y: " + str(self.y)

def main():
    vec = Vector2D(5,6)
    vec2 = Vector2D(2,3)
    print (vec)
    print (vec2)

    vec = vec + vec2
    print (vec)

    vec += vec2
    print (vec)

    vec = vec * vec2
    print(vec)

    print(vec.getLength())

    print(vec.normalized())


if __name__ == '__main__':
    main()

'''
import math
class Vector2D:
    def __init__(self, x, y):
        self.x = x
        self.y = y

    def __add__(self, other):
        return Vector2D(self.x + other.x, self.y + other.y)

    def __iadd__(self, other):
        self.x += other.x
        self.y += other.y
        return self

    def __sub__(self, other):
        return Vector2D(self.x - other.x, self.y - other.y)

    def __mul__(self, other):
        return Vector2D(self.x * other.x, self.y * other.y)

    def __truediv__(self, other):
        return Vector2D(self.x / other.x, self.y / other.y)

    def getLength(self):
        return math.sqrt(self.x**2 + self.y**2)

    def normalized(self):
        length = self.getLength()
        if length != 0:
            return Vector2D(self.x/length, self.y/length)
        return Vector2D(self)

    def __str__(self):
        return "X: " + str(self.x) + ", Y: " + str(self.y)

def main():
    vec = Vector2D(5,6)
    vec2 = Vector2D(2,3)
    print (vec)
    print (vec2)

    vec = vec + vec2
    print (vec)

    #don't add () at the end of the method so we only store the method address but not actually call the method

    tempmethod = (vec.getLength)

    vec += vec2
    print (vec)

    vec = vec * vec2
    print(vec)

    print(vec.getLength())

    #Now we call the method with the parens.  When we defined the var, the result was already calculated
    print(tempmethod())

    print(vec.normalized())

if __name__ == '__main__':
    main()
