#!/usr/bin/perl
use strict;
use Getopt::Long;

my %data;

#&sourceEnvVariables('/etc/netshelter/awsconfig.sh');

sub sourceEnvVariables {
   my $file = shift;
   open(FH, "< $file") || die "can't open $!\n";

   while (<FH>) {
      my ($key, $value) = ($1, $2) if (/export (\S+)=(.*)/);
      $ENV{$key} = $value;
   }
   close (FH);
}

GetOptions ("action|a=s"      => \$data{action},
	    "product|p=s"     => \$data{product},
	    "region|r=s"      => \$data{region},
	    "metrics|m=s"     => \$data{metrics},
  	    "granularity|g=s" => \$data{granularity},
  	    "help|h" 	      => \$data{help},
	    "verbose|v"       => \$data{verbose}
           );

my @all_asgs;
my $valid_asg_found;
my %metrics_options = ( GroupMinSize => "",
			GroupMaxSize => "",
			GroupDesiredCapacity => "",
			GroupInServiceInstances => "",
			GroupPendingInstances => "",
			GroupTerminatingInstances => "",
			GroupTotalInstances => ""
		    );

if (($data{action} ne 'disable' && $data{action} ne 'enable') || $data{product} eq "" || $data{metrics} eq "" || $data{help}) {
   help();
   exit;
}

my @metrics_list = split (/,/, $data{metrics});

foreach my $groupmetric (@metrics_list) {
   if (!(exists $metrics_options{$groupmetric})) {
      print "\nError: $groupmetric is an invalid metric\nPlease see the usage for the list of acceptable metrics\n\n";
      help();
      exit;
   }
}

$data{region} 		= "us-east-1" 			     if $data{region} eq "";
$data{granularity} 	= "1Minute"           		     if $data{granularity} eq "";
$data{granularity_arg} 	= "--granularity $data{granularity}" if $data{action} eq "enable";

$ENV{AWS_DEFAULT_REGION} = $data{region};

open (FH, 'aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[*].AutoScalingGroupName" |');

while (<FH>) {
   if (/\"(\S+)\"/) {
       push (@all_asgs, $1);
   }
}

foreach my $asg (@all_asgs) {
   if ($data{product} ne "" && $asg =~ /$data{product}/i) {
      $valid_asg_found = 1;
   } else {
      next;
   }
   print "Modifying ($data{action}) Group Metrics for ASG: $asg\n";
   foreach my $groupmetric (@metrics_list) {
      print "   Group Metric: $groupmetric\n";
      my $cmd = "aws autoscaling $data{action}-metrics-collection --region $data{region} --auto-scaling-group-name $asg --metrics \"$groupmetric\" $data{granularity_arg}";
      print "[DEBUG] Command to Execute: $cmd\n" if ($data{verbose});
      open (FH, "$cmd |");
   }
}

if (!$valid_asg_found) {
   print "\nError: $data{product} not found in the list of active ASGs\nPlease review your selected ASG\n\n";
}

sub help {
print<<EOF;
usage:
    modify-group-metrics.pl --action {disable|enable} --product <product> --metrics <metric1>,<metric2>,... [--region <region>] [--granularity <granularity>]
	--action,-a		"disable" or "enable"
    	--product,-p		product id, eg nrs-prd1
	--region,-r	 	aws region, eg us-west-1, us-east-1
	--granularity,-g	granularity, only 1Minute is valid at this time
 	--verbose,-v		more info
	--help,-h		help (this message)
	--metrics,-m		valid metrics:
			 		GroupMinSize
					GroupMaxSize
					GroupDesiredCapacity
					GroupInServiceInstances
					GroupPendingInstances
					GroupTerminatingInstances
					GroupTotalInstances
EOF
}
