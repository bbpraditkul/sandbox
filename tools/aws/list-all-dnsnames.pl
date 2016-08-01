#!/usr/bin/perl
use strict;

my $tagname=shift;

my %instance_tags;
my %instance_dns;

open (TAGS, 'aws ec2 describe-tags --output text --filter "Name=key,Values=Name" "Name=resource-type,Values=instance"|');

while (<TAGS>) {
   push (@{$instance_tags{$2}},$1) if (/\w+\s+\w+\s+(\S+)\s+\w+\s+(\S+)/);
}
close (TAGS);

open (INSTANCES, 'aws ec2 describe-instances --query "Reservations[*].Instances[*].[PrivateDnsName,PublicIpAddress,InstanceId]" --region us-west-1 --output text|');

while (<INSTANCES>) {
   $instance_dns{$3}=[$1,$2] if (/(\S+)\s+(\S+)\s+(\S+)/);
}

foreach my $tag (keys %instance_tags) {
   next if ($tag !~ /$tagname/);
   foreach my $instance_id (@{$instance_tags{$tag}}) {
      next if ($instance_dns{$instance_id}[0] =~ /NONE/i);
      print "$instance_dns{$instance_id}[1]	$instance_dns{$instance_id}[0]\n";
   }
}



