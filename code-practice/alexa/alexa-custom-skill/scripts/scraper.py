#!/usr/bin/env python

from __future__ import print_function
from bs4 import BeautifulSoup
import requests
import re

def getFile():
 # filename = "../data/LIST_OF_MEDS_FULL.txt"
  filename = "../data/LIST_OF_MEDS_UNIT.txt"
  f = open(filename)
  lines = f.readlines()
  return lines

def getURL(url):
  print ("working on " + url)

  page = requests.get(url)

  if page.status_code != 200:
     return
  else:
     str = ""

     soup = BeautifulSoup(page.text, 'html.parser')
     soup = soup.find("div", {"class": "entry clear"})

     my_elems = []

     for section in soup.find_all('h2'):
        if section.string == 'Summary':
           for p in section.find_next_sibling().encode_contents():
              my_elems.append(p)

              #str = re.sub(r'[^\x00-\x7F]+',' ', p)

     my_str = ''.join(my_elems)
     my_str = re.sub(r'<strong>Brand Names</strong>:','Brand names of this drug include ', my_str)

     my_str = re.search('([^<]*)', my_str)

     return my_str.group(1)

meds_dict = {}

for i in (getFile()):
   med = ''.join(i.lower().split())
   med = re.sub(' ', '', med)
   med = re.sub('- ', '', med)
   med = re.sub('/', '', med)
   med = re.sub('#2', '', med)
   med = re.sub('#', '', med)

   content = getURL("http://www.drugsdb.com/rx/"+ med +"/" +med+ "-side-effects/")
   if content == None:
      #retry as otc
      print ("retry this as an OTC")
      content = getURL("http://www.drugsdb.com/otc/"+ med +"/" +med+ "-side-effects/")
   else:
      print ("found this as an RX")

   if content == None:
      print ("Neither an RX or an OTC. Skipping...")
   else:
      print ("Adding " + med + " to the catalog")
      meds_dict[med] = content

open("../data/LIST_OF_MEDS_ADD.TXT", "w").close

with open("../data/side_effects_add.js", "w") as out:
   out.write("module.exports = {\n")
   counter = 0
   keys = len(meds_dict)
   for key, value in sorted(meds_dict.items()):
       counter += 1
       with open("../data/LIST_OF_MEDS_ADD.TXT", "a") as catalog:
          catalog.write(key + "\n")
       out.write( '  "' + key + '": "' + value + '"' )
       if counter != len(meds_dict):
           out.write(",\n")
       else:
           out.write("\n")
   out.write("}\n")
