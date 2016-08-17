#!/usr/bin/env python

import boto3

regions = ['us-west-1', 'us-west-2', 'us-east-1']

client = boto3.client('ec2')

for region in regions:
    print (region)
    ec2 = boto3.resource('ec2', region)
    tag = ec2.Tag('resource_id','key','value')

    instances = ec2.instances.filter(
        Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])
    print ("ID, PRV_DNS, PRV_IP, PUB_DNS, PUB_IP, TAGS")
    for instance in instances:
        print(instance.id, instance.private_dns_name, instance.private_ip_address, instance.public_dns_name, instance.public_ip_address, instance.tags)

"""
response = client.describe_tags(
    Filters=[
        {
            'Name': 'resource-id',
            'Values': ['i-c24841cd',]
        },
 #   ]
#)
#print response(Name)
"""