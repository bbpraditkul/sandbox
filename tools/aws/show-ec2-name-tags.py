#!/usr/bin/env python

#==================================================
#The following script lists all ec2 name tags
#
#usage: ./show-ec2-tags.py --tag <tag> --region <region> 
#

import argparse
from pprint import pprint
import boto.ec2
import yaml
import re

#from boto.connection import AWSAuthConnection

#==================================================
# config
#
config = yaml.load(file("/Users/bryanpraditkul/config.yaml"))


#==================================================
# Parse args
#
parser = argparse.ArgumentParser(description='Show all EC2 tags')

parser.add_argument('-t', '--tags', dest='tag', action='append', help='tag key', required=True)
parser.add_argument('-r', '--region', dest='region', action='append', help='region')
parser.add_argument('-v', '--verbose', action='store_true', help='verbose mode')

args = parser.parse_args()

#==================================================
# Retrieve all ec2 entries for the lookup
#
def getInstanceByRegion(region='us-west-1'):
    ec2conn = boto.ec2.connect_to_region(region,
   				         aws_access_key_id=config['aws_access_key_id'],
				         aws_secret_access_key=config['aws_secret_access_key'])
    reservations = ec2conn.get_all_instances()

    for reservation in reservations:
        for instance in reservation.instances:
            #print instance.tags[args.tag[0]], instance.state, instance.instance_type, instance.public_dns_name
            print "%35s %8s %11s %s" % (instance.tags[args.tag[0]], instance.state, instance.instance_type, instance.public_dns_name)

for region in args.region:
    getInstanceByRegion(region)
