#!/usr/bin/env python

import boto3
import sys

ec2 = boto3.resource('ec2')

"""
instance = ec2.create_instances(
    ImageId = 'ami-e689729e',
    MinCount = 1,
    MaxCount = 1,
    InstanceType='t2.micro')

print instance[0].id
"""

#for instance in ec2.instances.all():
#    print instance.id, instance.state

instances = ec2.instances.filter(
    Filters=[{'Name': 'instance-state-name', 'Values': ['running', 'stopped']}]
)

for i in instances:
    print i.id, i.instance_type, i.state