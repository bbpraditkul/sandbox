#!/usr/bin/python

import boto.ec2;

#MVP Phase I
#get all volumes (with tag names).
#any that don't have tags, tag them with tag-name of the instance that it's attached to
#
#Phase II
#parse the instance name tag and create the following tags:
#env, product, and component
#

def get_ec2_instances(region):

    ec2_conn = boto.ec2.connect_to_region(region)
    
    reservations = ec2_conn.get_all_instances()
     
    volumes = ec2_conn.get_all_volumes()

    for reservation in reservations:
        print region+':',reservation[0].instances[0].tags['Name']

    for vol_id in volumes:
        print region+':',vol_id

def main():
    regions = ['us-west-1','us-west-2']

    for region in regions: get_ec2_instances(region)

if __name__ =='__main__':main()
