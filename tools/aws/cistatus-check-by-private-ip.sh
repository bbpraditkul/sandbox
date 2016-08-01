#!/bin/bash

#utility defaults; alter if needed
#
region="us-east-1"
port=8080
max_tries=20;
max_wait=10;
wait_interval=30;
max_records=2000
delay=0

#utility necesssities
#
delimiter="%"
app_name=`basename $0`
primer_file="/etc/netshelter/awsconfig.sh"

if [[ -f $primer_file ]]
	then source $primer_file
else
	echo "[ERROR] $app_name could not find primer file \"$primer_file\"." 1>&2 ; exit 70
fi

while getopts s:e:a:r:p:d: opt
do
        case $opt in
                s) stack="$OPTARG";;
                e) environment="$OPTARG";;
                a) application="$OPTARG";;
                r) region="$OPTARG";;
		p) port="$OPTARG";;
		d) delay="$OPTARG";;
                *) echo "Error with options, likely due to an unsupported parameter or one passed without a value."; exit 64 ;;
        esac
done

if [[ $delay>0 ]]; then
	echo "[INFO] Waiting $delay seconds before executing"
	sleep $delay
fi

function get_ip(){

#Get the ASG lines from stack, environment, and application name
#
asg_lines=`as-describe-auto-scaling-groups --show-long --max-records $max_records --region $region --delimiter $delimiter | grep -i "$stack-$environment-$application""ASG"`

#Error if more than one ASG was found
#
if [[ `echo -e "$asg_lines" | grep -c "^AUTO-SCALING-GROUP"` > 1 ]]
	then echo "[ERROR] More than one Auto Scaling Group was found. $app_name can't determine which Auto Scaling Group to deploy to." 1>&2 ; exit 64
fi

#Error if no ASG was found
#
if [[ `echo -e "$asg_lines" | grep -c "^AUTO-SCALING-GROUP"` < 1 ]]
	then echo "[ERROR] No Auto Scaling Group was found. $app_name can't determine the Auto Scaling Group to deploy to." 1>&2 ; exit 64
fi

#Since those two conditions have been met, we're free to proceed
#
asg_group_name=`echo -e $asg_lines | grep "^AUTO-SCALING-GROUP" | cut -d "$delimiter" -f 2`

#Check that the ASG is not currently in "Suspended Processing" - this state prevents the termination of Auto Scaling Group instances
#
if [[ `echo -e "$asg_lines" | grep -c "SUSPENDED-PROCESS"` > 1 ]]
	then echo "[ERROR] Scaling Processes for the Auto Scaling Group $asg_group_name are currently suspended. $app_name needs scaling processes to complete the release." 1>&2 ; exit 64
fi

echo "[INFO] Auto Scaling Group $asg_group_name identified."

echo "[INFO] Getting Instances Behind Auto Scaling Group..."

#Stores the result of a request for an Auto Scaling Group description
#
asg_result=`as-describe-auto-scaling-groups $asg_group_name --show-long --max-records 999 -region $region`

#confirms that the selected Auto Scaling Group is not currently in state "Suspended Processing" - this state prevents the termination of Auto Scaling Group instances and thus prevents the release from completing
#
if [[ `echo -e "$asg_result" | grep -c "SUSPENDED-PROCESS"` > 1 ]]
	then echo "[ERROR] Scaling Processes for the Auto Scaling Group $asg_group_name are currently suspended. $app_name will now exit as scaling processes are required for the release to complete." 1>&2 ; exit 64
fi

#instanceidlist is list of all instances beloning to $asg_group_name
#
instanceidlist=`echo -e "$asg_result" | grep "^INSTANCE" | cut -d ',' -f2`

#if no instances found, warn
#
if [[ -z $instanceidlist ]]
	then echo "[INFO] No instances found belonging to $asg_group_name. Waiting." ;
fi

#id instanceidlist has value, lookup each instance to ensure instance is tagged correctly
#
echo "[INFO] Confirming that each instance found belongs to $asg_group_name"

if [[ -n $instanceidlist ]]
        then
        for instance in $instanceidlist
        do
                if [[ $asg_group_name == `ec2-describe-instances $instance --region $region | grep "^TAG.*aws:autoscaling:groupName" | cut -f5` ]]
                        then echo "[INFO] Instance $instance definitely belongs to $asg_group_name"
                        internal_ip=`ec2-describe-instances --show-empty-fields $instance | grep "INSTANCE" | cut -f18`;
                        echo "[INFO] $instance has an internal IP of $internal_ip"
		else echo "[INFO] Instance $instance doesn't yet belong to $asg_group_name. Retrying.";
		fi
	done
fi
}

get_ip;

cnt=1
echo "[INFO] Checking for server response..."
while [[ $cnt -le $max_tries && ! `nc -z -w$max_wait $internal_ip $port` =~ succeed ]]; do
	echo "[INFO] Server not yet available"
	echo "[INFO] Attempt: $cnt of $max_tries -- Waited $max_wait(s) for a response. Will retry in $wait_interval(s)"
	sleep $wait_interval
 	((cnt++))
	get_ip;
done
if [[ ! `nc -z -w$max_wait $internal_ip $port` =~ succeed ]]; then
	echo "[ERROR] Server was not available in the allotted time." ; exit 64;
else
	echo "[INFO] Success!  Server is running."
fi
