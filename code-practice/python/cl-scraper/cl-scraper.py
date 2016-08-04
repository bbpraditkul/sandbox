#!/usr/bin/env python3

#The following script attempts to query Craigslist for items and create a simple chart that highlights
# the current range of the item's cost
#
# Some other items
# http://sfbay.craigslist.org/search/cto?query=countryman&srchType=T&auto_transmission=1
#
# ref: this was a modification of an exercise originally found in the following tutorial
#     http://predictablynoisy.com/querying-craigslist-with-python/
#
import requests
from bs4 import BeautifulSoup as bs4
import pandas as pd
import numpy as np

locales = ['nby','sfc','sby','pen']

url_base = 'http://sfbay.craigslist.org/search/taa'
myparams = dict(query='rc')
rsp = requests.get(url_base, params=myparams)

#print ("Constructed URL: " + rsp.url)
#print (rsp.text[:500])

html = bs4(rsp.text, 'html.parser')
#print (html.prettify()[:1000])

cars = html.find_all('p', attrs={'class': 'row'})

print ("There are %d entries" % len(cars))

this_car = cars[1]
this_time = this_car.find('time')['datetime']
this_time = pd.to_datetime(this_time)
this_price = float(this_car.find('span', {'class': 'price'}).text.strip('$'))
#this_title = this_car.find('a', attrs={'class': 'hdrlink'}).text
this_title = this_car.find('span', {'id': 'titletextonly'}).text

#print (this_time)
#print (this_price)
#print (this_car.prettify())
print ('\n'.join([str(i) for i in [this_time, this_price, this_title]]) + '\n')

results = []
search_indices = np.arange(0,300,100)

for locale in locales:
    print ("working on " + locale)
    for i in search_indices:
        url = 'http://sfbay.craigslist.org/search/{0}/taa'.format(locale)
        print (url)

#==============================
# normalize the price data
#
def find_prices(results):
    prices = []
    for rw in results:
        price = rw.find('span', {'class': 'price'})
        if price is not None:
            price = float(price.text.strip('$'))
        else:
            price = np.nan
        prices.append(price)
    return prices

#==============================
# normalize the time data
#
def find_times(results):
    times = []
    for rw in apts:
        if time is not None:
            time = time['datetime']
            time = pd.to_datetime(time)
        else:
            time = np.nan
        times.append(time)
    return times
