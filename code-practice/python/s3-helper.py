#!/usr/bin/env python

import sys
import boto3

s3 = boto3.resource("s3")

for bucket_name in sys.argv[1:]:
    try:
        response = s3.create_bucket(Bucket=bucket_name)
        print response
    except Exception as error:
        print error

bucket_name = sys.argv[1]
object_name = sys.argv[2]
try:
    response = s3.Object(bucket_name, object_name).put(Body=open(object_name, 'rb'))
    print response
except Exception as error:
    print error


for bucket in s3.buckets.all():
    print bucket.name
    print "=items="
    for item in bucket.objects.all():
        print "\t%s" % item.key
