#! /usr/bin/env python3
import os
import json

account = input("Select an account: \n 1) Collective Health \n 2) CCHHDev \n [1,2?]: ")

if account != '1' and account != '2':
    print ("Invalid Option. Exiting...")
    exit(0)

if account == '1':
    print ("Collective Health")
    aws_sts_resp = os.popen("aws sts assume-role --role-arn 'arn:aws:sts::040171081634:role/devOpsL1' --role-session-name 'devOpsL1-collectivehealth' --profile devOpsL1").read()
elif account == '2':
    print ("CCHHDev")
    aws_sts_resp = os.popen("aws sts assume-role --role-arn 'arn:aws:sts::903670686538:role/DevOpsL1' --role-session-name 'DevOpsL1-cchhdev' --profile cchhdev").read()

parsed_aws_sts_resp = json.loads(aws_sts_resp)
with open("/Users/bryanpraditkul/.aws_creds", 'w+') as fh:
    fh.write("export AWS_ACCESS_KEY_ID=" + parsed_aws_sts_resp['Credentials']['AccessKeyId'] + "\n")
    fh.write("export AWS_SECRET_ACCESS_KEY=" + parsed_aws_sts_resp['Credentials']['SecretAccessKey'] + "\n")
    fh.write("export AWS_SESSION_TOKEN=" + parsed_aws_sts_resp['Credentials']['SessionToken'] + "\n")
    fh.close()
os.chmod("/Users/bryanpraditkul/.aws_creds", 0o777)