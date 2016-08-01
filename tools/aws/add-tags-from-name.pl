#!/opt/local/bin/perl

my %all_instance_names;

open (FH, "aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,Tags]' --region us-west-1 --output text|");

#printf "%20s %20s %20s %20s\n", "Instance ID", "Product", "Environment", "Component";

while (<FH>) {

    ($str1, $str2) = split (/\t/);
    #print "$str1 == $str2\n";
    chomp($str2);
    chomp($str1);

    if ($str1 =~ /(^i-\S+)/) {
       $instance_id = $1;
    }
    elsif ($str1 =~ /^Name/) {
       $instance_name = $str2;
    }
    else {
       next;
    }

    if ($instance_id ne '' && $instance_name ne '') {
       $all_instance_names{$instance_id} = $instance_name;
    }
}

foreach $key (keys %all_instance_names) {
    #print "$key = $all_instance_names{$key}\n";
    ($str_part_1, $str_part_2, $str_part_3) = split (/-/, $all_instance_names{$key});

    $product = $str_part_1;

    if ($str_part_2 =~ /((stg)|(prd)|(tst))\d*/i) {
       $environment = $1;
       $component = $str_part_3;
    }
    elsif ($str_part_3 =~ /((stg)|(prd)|(tst))\d*/i) {
       $environment = $1;
       $component = $str_part_2;
    }   

    #printf "%20s %20s %20s %20s\n", $instance_id, $product, $environment, $component;

    $add_tags_cmd = "aws ec2 create-tags --resources $key --tags Key=\"Product\",Value=\"$product\" Key=\"Component\",Value=\"$component\" Key=\"Environment\",Value=\"$environment\"";

    #open (FO, "$add_tags_cmd|");
    #sleep 5;

}


