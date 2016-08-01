#!/usr/bin/perl 
use Data::Dumper;
use Getopt::Long;

my ($environment, $type);

GetOptions  ("environment|e=s" => \$environment,
	     "type=s"	     => \$type
 	    ) or die ("Error in arguments\n");

#open (FO, "> az_instances.csv") || die "can't open file. $!";

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
	"m3.large" 	=> ".23",
	"m3.xlarge" 	=> ".45",
	"t1.micro" 	=> ".020",
	"c1.medium" 	=> ".145",
	"c3.large"	=> ".15",
	"c3.xlarge"	=> ".47",
	"i2.xlarge"	=> ".85",
	"i2.2xlarge"	=> "1.71",
	);

  my %monthly_cost_reserved_east_by_type = (
	"m1.small" => ["61",".034"], 
	"m1.medium" => ["122",".068"], 
  	"m1.large" => ["243",".136"],
	"m1.xlarge" => ["486",".271"],
	"m2.xlarge" => ["272",".169"],
	"m2.2xlarge" => ["544",".338"],
	"m2.4xlarge" => ["1088",".676"],
  	"m3.large" => ["220",".127"],
  	"m3.xlarge" => ["439",".254"],
	"t1.micro" => ["23",".012"],
	"c1.medium" => ["161",".09"],
	"c3.large" => ["167",".093"],
	"c3.xlarge" => ["333",".186"],
	"i2.large" => ["644",".369"],
	"i2.xlarge" => ["1288",".739"]
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
  open (FH, "aws ec2 describe-reserved-instances --query ReservedInstances[*].[AvailabilityZone,InstanceType,InstanceCount] --filters Name=state,Values=active --output text |");

  while (<FH>) {
      my $az;
      my $type;
      my $count;
   
      ($az, $type, $count) = ($1, $2, $3) if (/(\S+)\s+(\S+)\s+(\S+)/);

      $reservations{$az}{$type} = $count;
  }

  close (FH);
}

sub getInstanceSizeCount {

  my $region = shift;
  my %instance_info;
  my %asg_info;
  my $filters = "";

  if ($environment && $environment ne "") {$filters = "--filters Name=key-name,Values=$env_keys{$environment}";}

  open (FH, "aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,InstanceLifecycle,Placement]' --region $region --output text $filters |");
#i-234d5c46      c1.medium     spot   {u'Tenancy': 'default', u'GroupName': None, u'AvailabilityZone': 'us-east-1a'}

  while (<FH>) {
      my $instance_id;
      my $instance_type;
      my $lifecycle;
      my $az;

      ($instance_id, $instance_type, $lifecycle, $az) = ($1,$2,$3,$4) if (/(\S+)\s+(\S+)\s+(\S+).*\'(\w+-\w+-\w+)\'\}$/);
    
      $lifecycle = "non-spot" if $lifecycle =~ /none/i;
      $instance_info{$az}{$instance_type}{$lifecycle}++;
  }
 
  close (FH);


  print "=========================\n";
  print "======  $region  ======\n";
  print "=========================\n";
  printf "%12s %12s %10s %4s\n", "zone", "size", "type", "cnt";
  foreach $az (sort keys %instance_info) {
      my $cost_savings = 0;
      foreach $instance_type (keys %{$instance_info{$az}}) { 
	  foreach $lifecycle (keys %{$instance_info{$az}->{$instance_type}}) {
	      next if ($type ne "" && $lifecycle ne $type);
	      my $count = $instance_info{$az}->{$instance_type}->{$lifecycle};
	      my $reserved = 0;
	      $reserved = $reservations{$az}{$instance_type} if (exists $reservations{$az}{$instance_type}); 
              printf ("%12s %12s %10s %4d", $az, $instance_type, $lifecycle, $count) ;
	      if ($lifecycle eq 'non-spot') {
		  $cost_savings = ((&getCost($az,"ondemand",$instance_type)-(&getCost($az,"reserved",$instance_type)))*($count-$reserved));
		  printf "   *Reserved %4d -- Under-reserved %4d -- Cost Savings \$%-7.2f", $reserved,$count-$reserved,$cost_savings; 
		  $savings{"east"} += $cost_savings if ($az =~ /east/i);
		  $savings{"west"} += $cost_savings if ($az =~ /west/i);
 	      }
	      print "\n";
	  }
      }
  }

}

  print "\n========================================\n";
  printf " Overall cost East Savings: \$%-7.2f\n", $savings{"east"};
  printf " Overall cost West Savings: \$%-7.2f\n", $savings{"west"};
  print "========================================\n";

