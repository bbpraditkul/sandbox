#!/usr/bin/perl
use strict;
use Data::Dumper;
use Getopt::Long;

my %args;
my %ec2_instances;
my %counters;

GetOptions ("export|e"	     => \$args{export},
  	    "list|l=s"       => \$args{list},
  	    "region|r=s"     => \$args{region},
	    "group-name|g=s" => \$args{group_name},
	    "file|f=s" 	     => \$args{file},
  	    "verbose|v"      => \$args{verbose},
  	    "help|h"         => \$args{help}
 	   ) || die ("Error in arguments\n");

if ($args{help}) {
   print "usage: ./list-security-groups.pl --group-name|g STRING --file|f FILE [--verbose|v] [--help|h]\n";
   exit;
}

my $region;

if ($args{region} ne '') {
  $region = $args{region};
} else {
  print "region is required\n";
  exit;
}

#Map tag prefixes to instances
#
my %instance_tags;
open (TAGS, 'aws ec2 describe-tags --output text --filter "Name=key,Values=Name" "Name=resource-type,Values=instance"|');
while (<TAGS>) {
   if (/\w+\s+\w+\s+(\S+)\s+\w+\s+(\S+)/){
      my $instance_id_link = $1; #essentially maps the last id associated with the tag name
      my $tag = $2;
      my $tag_prefix = $1 if ($tag=~/(\w+-\w{3})/);
      $instance_tags{$tag_prefix} = $instance_id_link;
   } 
}
close (TAGS);

#Map instance to security groups
#
my %instance_security_groups;
open(EC2, "aws ec2 describe-instances --query \"Reservations[*].Instances[*].[InstanceId,SecurityGroups[*].GroupId]\"  --region \"$region\" --output text|");

my $instance;
while (<EC2>) {
  if (/(^i-\S+)/) {
     $instance = $1;
  }
  elsif (/(^sg-\S+)/) {
     push (@{$instance_security_groups{$instance}},$1);
  }
  else {
  }
}

#Describe security group attributes
#
my %security_groups;
my %security_group_lookup;
my ($group_id, $group_name);
my ($from_port, $to_port);
open (SG, "aws ec2 describe-security-groups --region $region --query \"SecurityGroups[*].[GroupId,GroupName,FromPort,ToPort,IpPermissions]\" --output text|");

while (<SG>) {
  if (/(^sg-\S+)\s+(\S+)/) {
     $counters{"0Total_Security_Groups"}++;
     $group_id = $1;
     $group_name = $2;
     @{$security_groups{$group_id}} = ();
     $security_group_lookup{$group_id}=$group_name;
  }
  elsif (/^(-?\d+)\s+\w+\s+(-?\d+)\s*$/) {
     ($from_port, $to_port) = ($1, $2);      
  }
  elsif (/^USERIDGROUPPAIRS\s+(\S+)\s+/) {
     push @{$security_groups{$1}}, ["$from_port-$to_port",$group_id];
  }
  else {
  }
}

print Dumper(\%security_groups);







#Output what we want to see
#

#foreach my $tag_prefix (keys %instance_tags) {
#  print "$tag_prefix - ";
#  foreach my $security_group_id (@{$instance_security_groups{$instance_tags{$tag_prefix}}}) {
#     print "$security_group_id - ";
#        foreach my $sg_entry (@{$security_groups{$security_group_id}}) {
#            print "@{$sg_entry}[0] @{$sg_entry}[1]\n";
#        }
#     print "\n";
#  }
#  print "\n";
#
#}
#
