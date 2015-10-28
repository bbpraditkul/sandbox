#!/usr/bin/perl
use HTTP::QuickBase;

$USER = "<your_user_name>";
$PW   = "<your_password>"; 


#https://www.quickbase.com/db/9wfsummi
#add your own database id here.
#I recommend using a test database.
$database_id = "9wfsummi";

#depending on what you hope to execute, uncomment the appropriate quickbase action.


#establish connection with db
my $qb;

if (!defined($qb)){
    $qb = new HTTP::QuickBase;
    $qb->authenticate($USER, $PW);
    if ($qb->error()) {
       die("$NAME: authentication error #". $qb->error(). ": ". $qb->errortext());
    }
}

#Add qb row
#$record{Text} = "CAT";
#$qb->AddRecord($database_id, %record);

#Edit qb row
#@records_t2 = $qb->doQuery($database_id, "{0.CT.''}", "3.6", "1", "");
#$record_id = $records_t2[0]{'Record ID#'};
#$new_record{Text} = "DOG";
#$qb->EditRecord($database_id, $record_id, %new_record);

#Delete qb row
#$qb->DeleteRecord($database_id, $record_id);

#Get qb rows
@records_t1 = $qb->doQuery($database_id, "{0.CT.''}", "1.2.3.4.5.6", "1", "");
foreach $record (@records_t1) {
    foreach $field (keys %$record){
        print "$field -> $record->{$field}\n";
    }
    print "\n";
}
