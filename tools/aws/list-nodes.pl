#!/usr/bin/perl
use strict;


my $product=shift;

if ($product eq "") {
   print "usage: list-nodes.pl <product[-environment]>\n\n"; 
   exit;
}

my %instances;

open (FH, "aws ec2 describe-instances --query 'Reservations[*].Instances[*].[PublicDnsName,Tags]' --output text |");

while (<FH>) {
   if (/^(.*\.amazonaws.com)\s.*\'(\S+ASG\S+)\'/) {
      my ($asg,$ec2) = ($2,$1);
      push (@{$instances{$asg}}, $ec2);
   }
}

foreach my $asg (sort keys %instances) {
   next if ($product ne "" && $asg !~ /${product}/i);
   printf "%-60s", $asg;
   my $cnt=0;
   foreach my $ec2 (@{$instances{$asg}}) {
      printf "%-60s", ' ' if $cnt>0;
      print "$ec2\n";
      $cnt++;
   }
}


