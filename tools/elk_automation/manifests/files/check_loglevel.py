#!/usr/bin/env python2.7

import requests
import spark
import numpy
import time
from datetime import datetime, timedelta
from pprint import pprint, pformat
import json
from subprocess import check_output

import logging
#logging.basicConfig(level=logging.DEBUG)

#index = now.strftime('logstash-%Y.%m.%d')
index = '_all'

def build_loglevel_query(loglevel, now, delta=timedelta(hours=1)):
  query = {
      'query': {
        'filtered': {
          'filter': {
            'range': {
              '@timestamp': {
                'from': (now - delta).isoformat(),
                'to': now.isoformat()
              }
            }
          },
          'query': {
            'query_string': {
              'query': '@fields.loglevel:"{0}" AND @tags:"{1}"'.format(loglevel, "real-time-bidder"),
            }
          }
        }
      },
      'from': 0,
      'size': 0,
    }
  logging.debug(pformat(query))

  return query

for loglevel in ['FATAL', 'ERROR', 'WARN', 'INFO']:
  results = []
  for hour in range(-12, 1):
    now = datetime.utcnow() + timedelta(hours=hour)
    logging.debug(now.isoformat())
    q = build_loglevel_query(loglevel, now)

    post = requests.post('http://inw-48.rfiserve.net:9200/{0}/_search'.format(index), data=json.dumps(q))

    logging.debug(pformat(post.request.url))
    logging.info(pformat(post.json))
    
    results.append(post.json['hits']['total'])


  now = datetime.utcnow() - timedelta(minutes=5)
  logging.debug(now.isoformat())
  q = build_loglevel_query(loglevel, now, delta=timedelta(minutes=5))

  post = requests.post('http://inw-48.rfiserve.net:9200/{0}/_search'.format(index), data=json.dumps(q))

  logging.debug(pformat(post.request.url))
  logging.info(pformat(post.json))
  
  last_5 = post.json['hits']['total']

  diff = map(lambda x: x[0]-x[1], zip(results[1:], results))
  diff = ','.join(map(str, diff))
  print u"{0}:\t{2} {1} ({3:.1f})({4:.1f}) {5}".format(loglevel, results[-1], spark.spark_string(results, fit_min=True), numpy.average(results), numpy.average(results)/12, last_5)
