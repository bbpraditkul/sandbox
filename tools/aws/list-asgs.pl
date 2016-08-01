#!/usr/bin/perl -w
use Data::Dumper;

#my %instance_info;

open (FO, "> asg_instances.csv") || die "can't open file. $!";

&get_instance_size_count("us-east-1");
&get_instance_size_count("us-west-1");

my $nonprdonly=0;
my $product = '';

sub get_instance_size_count {

  my $region = shift;
  my %instance_info;
  my %asg_info;

  open (FH, "aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,InstanceType]' --region $region --output text |");


  while (<FH>) {
      my $instance_id;
      my $instance_type;

      ($instance_id, $instance_type) = ($1,$2) if (/(\S+)\s+(\S+)/);
    
      $instance_info{$instance_id} = $instance_type;
  }
 
  close (FH);

  open (FH, "aws autoscaling describe-auto-scaling-instances --query 'AutoScalingInstances[*].[AutoScalingGroupName,InstanceId]' --output text --region $region |");

  while (<FH>) {
      my $asg_id;
      my $instance_id;
   
      ($asg_id, $instance_id) = ($1, $2) if (/(\S+)\s+(\S+)/);

      $asg_id =~ s/ASG-.*$//;
      $asg_info{$asg_id}{$instance_info{$instance_id}}++;
  }

  close (FH);

  print "=========================\n";
  print "======  $region  ======\n";
  print "=========================\n";
  foreach $i (sort keys %asg_info) {
      foreach $size (keys %{$asg_info{$i}}) { 
	  next if ($i =~ /-prd\d?-/ && $nonprdonly);
          print "$i\n";
      }
  }

}



