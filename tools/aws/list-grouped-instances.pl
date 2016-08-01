#!/usr/bin/perl
use strict;


my $product=shift;

my %instances;
my $count;

open (FH, "aws ec2 describe-instances --filters Name=instance-state-name,Values=running --query 'Reservations[*].Instances[*].[InstanceType,Tags]' --region us-west-1 --output text |");

  my $instancetype;
while (<FH>) {
     $instancetype = $1 if (/^(\w\d\.\w+)/);
  if (/^Name\s+(\w+)-(\w+)/) {
     my $product = $1;
     my $envcluster = $2;
     $instances{$product}{$envcluster}{$instancetype}++; 
     $count++;
  }
}

close (FH);

open (FH, "aws ec2 describe-instances --filters Name=instance-state-name,Values=running --query 'Reservations[*].Instances[*].[InstanceType,Tags]' --region us-west-2 --output text |");

while (<FH>) {
     $instancetype = $1 if (/^(\w\d\.\w+)/);
  if (/^Name\s+(\w+)-(\w+)/) {
     my $product = $1;
     my $envcluster = $2;
     $instances{$product}{$envcluster}{$instancetype}++; 
     $count++;
  }
}

close (FH);




print "PRODUCT	ENVCLUSTER	INSTANCETYPE	NUMBER_OF_INSTANCES\n";
foreach my $product (keys %instances){
#  print "$product\n";
  foreach my $envcluster (keys $instances{$product}) {
     foreach my $instancetype (keys $instances{$product}{$envcluster}) {
         #print "     $envcluster --> $instancetype --> $instances{$product}{$envcluster}{$instancetype}\n";
         print "$product,$envcluster,$instancetype,$instances{$product}{$envcluster}{$instancetype}\n";
     }
  }
}

print $count++;

