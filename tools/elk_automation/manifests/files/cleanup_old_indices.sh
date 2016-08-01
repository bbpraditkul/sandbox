#!/bin/bash
#
# Wrapper script to maintain retention of indices on ElasticSearch cluster
#
CURATOR_BIN=/opt/python/2.7/bin/curator
NC=/usr/bin/nc
ES_PORT=9200
RETENTION_INDICES_DAYS=60  # days
CLOSE_INDICES_DAYS=40 # days. Close the references to indices open for long. Hogs ES memory.

if [ ! -e ${CURATOR_BIN} ]; then
  echo "ERROR| Curator is not installed! " 2>&1
  exit 1
fi

$NC -z localhost $ES_PORT
status=$?

if [ $status -ne 0 ]; then
  echo "ERROR| ElasticSearch cluster not responding" 2>&1
  exit 1
fi

$CURATOR_BIN --host localhost -d ${RETENTION_INDICES_DAYS} -c ${CLOSE_INDICES_DAYS}
status=$?

if [ $status -ne 0 ]; then
  echo "ERRORS running curator" 2>&1
  exit $status
fi
