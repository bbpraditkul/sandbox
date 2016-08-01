#!/usr/bin/perl 
use Data::Dumper;
use Getopt::Long;
use strict;

#BP - 20140417: the cost portion of the script was never completed.  It will need tweaking for that info.

my ($environment, $type);

GetOptions  ("environment|e=s" => \$environment,
	     "type=s"	     => \$type
 	    ) or die ("Error in arguments\n");


my %reservations;
my %savings;

my %env_keys = (
	"prd"	=> "prd,prd-w,ops,release",
	"qa"	=> "qa,qa-w",
	"dev"	=> "dev,dev-w"
	);


&getReservations();
&getInstanceSizeCount("us-east-1");
&getInstanceSizeCount("us-west-1");

sub getCost ($$$) {

  my ($zone,$type,$size) = @_;

  my %monthly_cost_ondemand_east_by_type = (
	"m1.small" 	=> ".060",
	"m1.medium" 	=> ".120",
  	"m1.large" 	=> ".240",
	"m1.xlarge" 	=> ".480",
	"m2.xlarge" 	=> ".410",
	"m2.2xlarge" 	=> ".820",
	"m2.4xlarge" 	=> "1.640",
	"t1.micro" 	=> ".020",
	"c1.medium" 	=> ".145"
	);

  my %monthly_cost_reserved_east_by_type = (
	"m1.small" => ["169",".014"], 
	"m1.medium" => ["338",".028"], 
  	"m1.large" => ["676",".056"],
	"m1.xlarge" => ["1352",".112"],
	"m2.xlarge" => ["789",".068"],
	"m2.2xlarge" => ["1578",".136"],
	"m2.4xlarge" => ["3156",".272"],
	"t1.micro" => ["62",".005"],
	"c1.medium" => ["450",".036"]
	);

  my %monthly_cost_ondemand_west_by_type = (
	"m1.small" 	=> ".065",
	"t1.micro" 	=> ".025",
	"c1.medium" 	=> ".165"
	);

  my %monthly_cost_reserved_west_by_type = (
	"m1.small" => ["169",".022"], 
	"t1.micro" => ["62",".008"],
	"c1.medium" => ["450",".057"]
	);


  if ($zone =~ /east/i) {  
     if ($type =~ /reserved/i) {
        return $monthly_cost_reserved_east_by_type{$size}[0]/12+$monthly_cost_reserved_east_by_type{$size}[1]*30*24;
     } else { #ondemand
        return $monthly_cost_ondemand_east_by_type{$size}*30*24;
     }
  }
  elsif ($zone =~ /west/i) {
     if ($type =~ /reserved/i) {
        return $monthly_cost_reserved_west_by_type{$size}[0]/12+$monthly_cost_reserved_west_by_type{$size}[1]*30*24;
     } else { #ondemand
        return $monthly_cost_ondemand_west_by_type{$size}*30*24;
     }
  }

}

sub getReservations {
  open (FH, "aws rds describe-reserved-db-instances --query ReservedDBInstances[*].[MultiAZ,DBInstanceClass,DBInstanceCount,State] --output text |"); #Filters don't work for aws 

  while (<FH>) {
      my $az;
      my $type;
      my $count;
      my $state;

      ($az, $type, $count, $state) = ($1, $2, $3, $4) if (/(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/);

      next if ($state ne "active");

      $reservations{$az}{$type} = $count;
  }

  close (FH);
}

sub getInstanceSizeCount {

  my $region = shift;
  my %instance_info;
  my %db_name;
  my %asg_info;
  my $filters = "";

  if ($environment && $environment ne "") {$filters = "--filters Name=key-name,Values=$env_keys{$environment}";}

  open (FH, "aws rds describe-db-instances --query 'DBInstances[*].[MultiAZ,DBInstanceIdentifier,DBInstanceClass]' --region $region --output text $filters |");
#i-234d5c46      c1.medium     spot   {u'Tenancy': 'default', u'GroupName': None, u'AvailabilityZone': 'us-east-1a'}

  while (<FH>) {
      my $instance_id;
      my $instance_type;
      my $lifecycle = "na";
      my $az;

      ($az, $instance_id, $instance_type) = ($1,$2,$3) if (/(\S+)\s+(\S+)\s+(\S+)/);
    
      $lifecycle = "non-spot" if $lifecycle =~ /none/i;
      $instance_info{$az}{$instance_type}{$lifecycle}++;
      push (@{$db_name{$az}{$instance_type}}, $instance_id);
      
  }
 
  close (FH);


  print "=========================\n";
  print "======  $region  ======\n";
  print "=========================\n";
  printf "%8s %16s %4s\n", "zone", "size", "cnt";
  foreach my $az (sort keys %instance_info) {
      my $cost_savings = 0;
      foreach my $instance_type (keys %{$instance_info{$az}}) { 
	  foreach my $lifecycle (keys %{$instance_info{$az}->{$instance_type}}) {
	      next if ($type ne "" && $lifecycle ne $type);
	      my $count = $instance_info{$az}->{$instance_type}->{$lifecycle};
	      my $reserved = 0;
	      $reserved = $reservations{$az}{$instance_type} if (exists $reservations{$az}{$instance_type}); 
              printf ("%8s %16s %4d", $az, $instance_type, $count) ;
	      if ($lifecycle eq 'non-spot' || $lifecycle eq 'na') {
		  $cost_savings = ((&getCost($az,"ondemand",$instance_type)-(&getCost($az,"reserved",$instance_type)))*($count-$reserved));
		  printf "   *Reserved %4d -- Under-reserved %4d", $reserved,$count-$reserved; 
		  $savings{"east"} += $cost_savings if ($az =~ /east/i);
		  $savings{"west"} += $cost_savings if ($az =~ /west/i);
 	      }
	      print "\n";
	  }
	  print "\n      Used by:\n";
	  foreach my $instance_id (@{$db_name{$az}{$instance_type}}) {
                print "         $instance_id\n";
          }
	  print "\n";
      }
  }

}



