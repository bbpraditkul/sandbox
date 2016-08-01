#!/bin/bash

#Added due to laziness (issues with env when running in cron)
#export AWS_PATH=/opt/aws
#export AWS_AUTO_SCALING_HOME=/opt/aws/apitools/as
#export JAVA_HOME=/usr/lib/jvm/java

request=$2

#Add if running on bootstrapped instance
#source /etc/netshelter/awsconfig.sh

for i in `${AWS_AUTO_SCALING_HOME}/bin/as-describe-auto-scaling-groups --max-records 1000 --delimiter % | grep $1 | grep AUTO | cut -d% -f2`; do
 echo "updating: $i"
 ${AWS_AUTO_SCALING_HOME}/bin/as-$request-processes $i
done
