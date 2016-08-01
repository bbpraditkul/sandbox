#!/usr/bin/env python



import boto3

MIN_RECORDS = 49

regions = ['us-west-1', 'us-west-2', 'us-east-1']



for region in regions:
    print region
    ec2 = boto3.resource('ec2', region)
    security_group = ec2.SecurityGroup('id')

    #instances = ec2.instances.filter(
    #    Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])
    #for instance in instances:
    #    print(instance.id, instance.instance_type)

    #list ipranges for each SG

    d = dict()

    for sgs in ec2.security_groups.all():
        group_name = sgs.group_name
        my_list = []
        for access_entries in sgs.ip_permissions:
            #if not access_entries['IpRanges']:
            #    pass
            #else:
            my_list.append(access_entries)
            for cidrs in access_entries['IpRanges']:
                my_list.append(cidrs)
            #        print cidrs
            if len(my_list) > MIN_RECORDS:
                print group_name + ': ' + str(len(my_list)) + ' records'





