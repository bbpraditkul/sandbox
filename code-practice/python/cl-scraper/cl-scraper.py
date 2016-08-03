#!/usr/bin/env python3

#http://sfbay.craigslist.org/search/cto?query=countryman&srchType=T&auto_transmission=1

import requests
from bs4 import BeautifulSoup as bs4

url_base = 'http://sfbay.craigslist.org/search/cto'
myparams = dict(query='countryman', srchType='T', auto_transmission=1)
rsp = requests.get(url_base, params=myparams)

#print ("Constructed URL: " + rsp.url)
#print (rsp.text[:500])

html = bs4(rsp.text, 'html.parser')
print (html.prettify()[:1000])

cars = html.find_all('p', attrs={'class': 'row'})

print ("There are %d entries" % len(cars))

this_car = cars[1]

print (this_car.prettify())