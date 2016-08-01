#!/usr/bin/perl
use strict;
use Data::Dumper;
use Getopt::Long;

my %args;
my %ec2_instances;
my %counters;

GetOptions ("non-dry-run|n"  => \$args{nondryrun},
	    "export|e"	     => \$args{export},
  	    "list|l=s"       => \$args{list},
  	    "region|r=s"     => \$args{region},
	    "group-name|g=s" => \$args{group_name},
	    "file|f=s" 	     => \$args{file},
  	    "verbose|v"      => \$args{verbose},
  	    "help|h"         => \$args{help}
 	   ) || die ("Error in arguments\n");

if ($args{help}) {
   print "usage: ./clean-security-groups.pl --group-name|g STRING --file|f FILE [--verbose|v] [--help|h]\n";
   exit;
}

my $region;
my $group_id;
my $group_name;
my %security_groups;
my $from_port;
my $to_port;
my %security_group_lookup;

if ($args{region} ne '') {
  $region = $args{region};
} else {
  print "region is required\n";
  exit;
}

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

my %groups_in_use;

open(EC2, "aws ec2 describe-instances --region \"$region\" --query \"Reservations[*].Instances[*].SecurityGroups[*].GroupId\" --output text|");

my %instance_security_groups;

while (<EC2>) {
  print $_;
  if (/(^sg-\S+)/) {
     $groups_in_use{$1}++;
  }
  else {
  }
}

#foreach my $groupid (keys %groups_in_use) {
#}
  
my %delete_candidates;

foreach my $id (keys %security_groups) {
  my $group_name = $security_group_lookup{$id};
  if (exists $groups_in_use{$id}) {
    print "Security Group $id($group_name) is in use.  Skipping...\n";
    $counters{"1Used_Security_Groups"}++;
  }
  elsif ( defined @{$security_groups{$id}}[0] ) {  
    print "Security Group $id($group_name) is unused but linked to \n";
    print "(Will unlink on non-dry-run):\n";
    foreach my $range_group_pair (@{$security_groups{$id}}) {
       my ($port_range, $source_sgs) = (@{$range_group_pair}[0],@{$range_group_pair}[1]);
       $port_range = "all" if ($port_range eq "-1--1");
       printf "  %-10s %30s %20s\n", $source_sgs, $security_group_lookup{$source_sgs}, $port_range;
       print "  Would have executed: ./aws ec2 revoke-security-group-ingress --region \"$region\" --source-group \"$source_sgs\" --group-id \"$id\" --protocol \"tcp\" --port \"$port_range\"\n" if ($args{verbose});
       print "  Would have executed: ./aws ec2 revoke-security-group-ingress --region \"$region\" --source-group \"$source_sgs\" --group-id \"$id\" --protocol \"tcp\" --port \"$port_range\"\n" ;
       open (TMP, "aws ec2 revoke-security-group-ingress --region \"$region\" --source-group \"$source_sgs\" --group-id \"$id\" --protocol \"tcp\" --port \"$port_range\"|") if ($args{nondryrun});
    }
    print "Would delete security group $id($group_name) on non-dry-run\n";
    print "Would have executed ./aws ec2 delete-security-group --region \"$region\" --group-id $id\n" if ($args{verbose});
    open (TMP, "aws ec2 delete-security-group --region \"$region\" --group-id $id|") if ($args{nondryrun});
    $counters{"2Linked_Security_Groups"}++;
    $counters{"1Unused_Security_Groups"}++;
  }
  elsif ( !defined @{$security_groups{$id}}[0] ) {
    print "Security Group $id($group_name) is already unlinked\n";
    print "Would delete $id($group_name) on non-dry-run\n";
    open (TMP, "aws ec2 delete-security-group --region \"$region\" --group-id $id|") if ($args{nondryrun});
    $counters{"2Unlinked_Security_Groups"}++;
    $counters{"1Unused_Security_Groups"}++;
  }
  print "\n","="x80,"\n\n";
}

print "[Summary]\n";

foreach my $metric (sort keys %counters) {
  my $pmetric =$1 if ($metric =~ /^\d(.*)/); 
  printf " %30s %d\n", $pmetric, $counters{$metric};
}
