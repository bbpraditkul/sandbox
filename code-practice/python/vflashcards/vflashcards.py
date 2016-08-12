#!/usr/bin/env python3

import re
import random

__author__ = "Bryan Praditkul"

"""The following script was a simple tool for my son to remember a few Thai phrases.
Flash cards are a fun and easy way to quickly remember things
"""

def main():
    user_option = 'Y'
    q_and_a_list = []
    count = 0

    f_in = open('flashcards.txt','r')

    for line in f_in.read().split('\n'):
        if not line.strip():
            pass
        else:
            kv = line.split('|')
            q_and_a_list.append(kv)
            count += 1

    f_in.close()

    print ("Welcome to the Virtual Flashcard Script\n"
          "Let's get started...")

    while re.search('[Yy]', user_option):
        index = random.randint(0,count-1)
        print ("\n      ", q_and_a_list[index][0], "\n")
        input("Hit 'Enter' to get the answer...\n")
        print ("      ", q_and_a_list[index][1], "\n")
        user_option = input("Continue? [Yy|Nn] (default:'Y'): ") or 'Y'
        print ("\n"*1000)

if __name__ == "__main__":
    main()