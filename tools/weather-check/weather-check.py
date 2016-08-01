#!/usr/bin/env python

"""
The following just queries the wunderground API for weather data
usage:
    weather-check.py
    >> Enter City, State
"""

import urllib2
import json
import re

city = raw_input('enter city: ')
state = raw_input('enter state: ')

if state is None:
    state = 'CA'

city = re.sub(" ", "_", city)

#f = urllib2.urlopen('http://api.wunderground.com/api/5ba5e0340ea6c02b/geolookup/conditions/q/CA/' + city + '.json')
try:
    f = urllib2.urlopen('http://api.wunderground.com/api/5ba5e0340ea6c02b/forecast/q/' + state.upper() + '/' + city + '.json')
    json_string = f.read()
    parsed_json = json.loads(json_string)
    forecast = {}

    for day in range(0,4):
        date = parsed_json['forecast']['simpleforecast']['forecastday'][day]['date']['pretty']
        low  = parsed_json['forecast']['simpleforecast']['forecastday'][day]['low']['fahrenheit']
        high = parsed_json['forecast']['simpleforecast']['forecastday'][day]['high']['fahrenheit']
        conditions = parsed_json['forecast']['simpleforecast']['forecastday'][day]['conditions']
        forecast[day] = {"date": date,
                     "low": low,
                     "high": high,
                     "conditions": conditions}

    for forecast_day in forecast.items():
        print forecast_day

    f.close()

except KeyError, e:
    print "No forecast for location.  Please try again"
