#/bin/sh

# Author: Bryan Praditkul
# Date: 201407 
#
# Notes: just a quick but useful hack to show instance detail on the command line in a more readable format
#  There's no error checking as it was needed in a pinch, so please take use with caution
#  You never know when AWS might change their api parameters :)
#

aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,Tags]' --region us-west-1 --output text | egrep ^Name | perl -pe 's/^Name\s+//g'
