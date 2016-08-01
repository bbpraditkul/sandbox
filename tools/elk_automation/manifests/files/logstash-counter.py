#!/usr/bin/env python2.7

try:
  import cPickle as pickle
except ImportError:
  import pickle
import logging
import logging.config
import json
import pprint
import socket
import struct
import signal  # Not used, but docs say makes KeyboardInterrupt work in threads
import sys
from time import sleep, time
from threading import Thread, Lock, active_count
from yaml import load
try:
  from yaml import CLoader as Loader
except ImportError:
  from yaml import Loader

with open('logstash-counter.yml') as config_yaml:
  config = load(config_yaml, Loader=Loader)

if sys.version_info[0] == 3 or (
    sys.version_info[0] == 2 and sys.version_info[1] >= 7):
  logging.config.dictConfig(config['logging'])
  logger = logging.getLogger('logstash-counter')
else:
  logger = logging.getLogger(__name__)
  logger.setLevel(logging.INFO)
  ch = logging.StreamHandler(sys.stdout)
  ch.setLevel(logging.DEBUG)

  # create formatter
  formatter = logging.Formatter('%(asctime)s %(levelname)s %(module)s:%(lineno)d - %(message)s')

  # add formatter to ch
  ch.setFormatter(formatter)

  # add ch to logger
  logger.addHandler(ch)

logger.debug(pprint.pformat(config))

try:
  LOGSTASH_HOST = config['logstash_host']
  LOGSTASH_PORT = config['logstash_port']
  GRAPHITE_HOST = config['graphite_host']
  GRAPHITE_PORT = config['graphite_port']
except KeyError as e:
  raise KeyError("Config missing required element: {0}".format(e.message))

class Monitor(object):
  pass

monitors = {}
type_mapping = {}
for key, value in config['monitors'].items():
  monitor = Monitor()
  monitor.name = key
  monitor.is_field = value.get('is_field', False)
  monitor.type = value['type']

  if monitor.type not in type_mapping:
    type_mapping[monitor.type] = []
  type_mapping[monitor.type].append(monitor)
  
  monitor.event_cardinality = value.get('event_cardinality', 1)
  monitor.global_cardinality = value.get('global_cardinality', sys.maxint)
  monitor.graphite_namespace = value['graphite_namespace']

  monitor.mangle = []
  for mangle in value.get('graphite_mangle', []):
    monitor.mangle.append(mangle)

  monitor.results = {}
  monitor.lock = Lock()
  monitors[key] = monitor


def handle_events(events):
  for event in events:
    event_json = None
    try:
      event_json = json.loads(event)
    except ValueError:
      print event
      sys.exit(1)

    if "_grokparsefailure" in event_json['@tags']:
      continue

    if event_json['@type'] not in type_mapping:
      continue
    for monitor in type_mapping[event_json['@type']]:
      monitor_key = monitor.name

      try:
        if monitor.is_field:
          monitor_list = event_json['@fields'][monitor_key]
        else:
          monitor_list = event_json[monitor_key]
      except KeyError:
        print event_json
        sys.exit(1)
      if len(monitor_list) > monitor.event_cardinality:
        print monitor_list
        sys.exit(1)

      for monitor_item in monitor_list:
        with monitor.lock:
          if monitor_item not in monitor.results:
            monitor.results[monitor_item] = 0
          monitor.results[monitor_item] += 1


def process_stream():
  s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
  s.connect((LOGSTASH_HOST, LOGSTASH_PORT))
  logger.info("Connected to logstash")

  leftover = None
  while True:
    data = s.recv(4096)
    events = data.strip().split('\n')
    if leftover:
      events[0] = leftover + events[0]
      leftover = None
    if not events[-1].endswith('"}'):
      leftover = events[-1]
      del events[-1]
    handle_events(events)


def ship_data():
  s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
  s.connect((GRAPHITE_HOST, GRAPHITE_PORT))
  logger.info("Connected to graphite")
  while True:
    sleep(10)
    to_send = []
    timestamp = int(time())
    for monitor in monitors.values():
      with monitor.lock:
        if len(monitor.results) > monitor.global_cardinality:
          raise Exception(
              "Too many keys in results for monitor {0}".format(monitor.name))
        for key in monitor.results.keys():
          mangle_key = key
          for mangle in monitor.mangle:
            mangle_key = mangle_key.replace(*mangle)
          to_send.append(
              ("{0}.{1}".format(monitor.graphite_namespace, mangle_key), 
               (timestamp, monitor.results[key])))
          monitor.results[key] = 0
      payload = pickle.dumps(to_send)
      header = struct.pack("!L", len(payload))
      message = header + payload
      s.send(message)

if __name__ == "__main__":
  expected_threads = 1

  stream_thread = Thread(target=process_stream)
  stream_thread.daemon = True
  expected_threads += 1

  ship_thread = Thread(target=ship_data)
  ship_thread.daemon = True
  expected_threads += 1

  stream_thread.start()
  ship_thread.start()

  try:
    while True:
      sleep(1)
      if active_count() != expected_threads:
        logger.critical("A child thread has died")
        sys.exit(1)
  except KeyboardInterrupt:
    sys.exit(0)
