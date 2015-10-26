#!/usr/bin/env python

"""
The following hack repeats a preformatted block with dynamic values...simple
"""

filename = "block-output.txt"
val1_step_interval = 3
val2_step_interval = 7


def constructBlock(multiplier):
    out = []
    out.append("{")
    out.append("   custom vhost definition id:" + str(multiplier))
    out.append("   timeout: " + str(val1_step_interval) )
    out.append("   foreign_id:" + str(val2_step_interval*multiplier))
    out.append("}")
    out.append("")
    return '\n'.join(out)

f = open(filename, 'wb')
for i in range(1,10):
    #print (i, ": ", constructBlock(), file=filename)  #python 3.x
    print >> f, constructBlock(i)


