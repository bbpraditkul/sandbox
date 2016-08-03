#!/usr/bin/env python
from __future__ import print_function
import re

filename = "../data/LIST_OF_CONTACTS_FULL.txt"
f = open(filename)
lines = f.readlines()
lines = ''.join(lines)

#retrieve each employee
employees = lines.split('\n\n')

employee_dict = {}

for employee in employees:
   #flatten each employee into a single string and then to an list
   employee = re.sub('^\s*','',employee)
   employee = re.sub('\n', '|', employee)
   employee = employee.split('|')
   if employee[0] != '':
     employee_name = employee[0].split(',')
   employee_name_str = employee_name[1] + ' ' + employee_name[0]
   employee_name_str = re.sub('^\s*','',employee_name_str)
   employee_name_str = employee_name_str.lower()
   department_office = employee[2].split('-')
   employee_str = '"' + employee_name_str + '": "' + employee_name_str + " is a " + employee[1] + ".  This member of the collective sits in the " + department_office[0] + " department of the " + department_office[1] + ' office."'
   employee_dict[employee_name_str] = employee_str

open("../data/LIST_OF_EMPLOYEES.TXT", "w").close

with open("../data/employees.js", "w") as out:
   out.write("module.exports = {\n")
   counter = 0
   employee_cnt = len(employee_dict)
   for key, value in sorted(employee_dict.items()):
       counter += 1
       with open("../data/LIST_OF_EMPLOYEES.TXT", "a") as catalog:
          catalog.write(key + "\n")
       out.write( value )
       if counter != len(employee_dict):
           out.write(",\n")
       else:
           out.write("\n")
   out.write("}\n")

