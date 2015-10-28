#! /usr/bin/perl #-w
#-----------------------------------------------------------
# $Id: qb_bf_bridge.pl,v 1.0 2006/02/09 00:00:00 bpraditk Exp $
# $Source: unknown $
#-----------------------------------------------------------

# summary: check for build/deploy request.  
# If any exist in a "requested" state,
# check to see if buildforge has this entry.  
# If not, enter it and request the build.
#

use HTTP::QuickBase;
use Data::Dumper;
use BuildForge::API;
use BuildForgeInterface;
#use strict;

$| = 1;

#**************************************
# Quickbase IDs 
# pcomp_qb_id: project component quickbase
# breq_qb_id:  build request quickbase
# dreq_qb_id:  deployment request quickbase
# dattp_qb_id: deployment attempts quickbase
#
my $pcomp_qb_id = "<my_qb_id>";
my $breq_qb_id  = "<my_qb_id>";
my $dreq_qb_id  = "<my_qb_id>";
my $dattp_qb_id = "";

#**************************************
# Authenticate
#
my %CONFIG;
my $USER = "**********";
my $PASS = "**********";

#**************************************
# Debug Setting (0|1)
# 
my $debug = 0;

#**************************************
# LogLevel (0|1|2)
# 
my $loglevel = 1;

#**************************************
# Data structures
#
				#table of request records (by record ids)
my (%pcomp_data,%breq_data,%dreq_data);
				#mapping of field id to names
my (%pcomp_field_map,%breq_field_map,%dreq_field_map);
				#mapping of quickbase to buildforge
my %bf_record;
my ($brequests,$drequests);   	#list of new build/deploy requests
my (%error_tree, $err);     	#error list if things go awry
my $qb;

#**************************************
# Data field maps
#
&init_data_map();

#**************************************
# Initialize DB Connections:
#
&init($pcomp_qb_id);
&init($breq_qb_id);
&init($dreq_qb_id);

#**************************************
# Initialize BuildForge Connection:
#
#my $api = BFI->login();

&main();  

#**************************************
# main() - 
#
# check for build/deploy request.  If any exist in a "requested" state,
# check to see if buildforge has this entry.  If not, enter it and request the build.
#
sub main () {

 my %new_reqs;



 # query the request databases for any changed records where "Status" = "Requested"
 # once retrieved, we need to check if buildforge already has this entry.  This still needs to be coded.
  
 ($err,$brequests) = &check_for_request($breq_qb_id, \%breq_field_map);
 &die_error_tree if ($err);

 ($err,$drequests) = &check_for_request($dreq_qb_id, \%dreq_field_map);
 &die_error_tree if ($err);

 if (@{$brequests} == 0 && @{$drequests} == 0){
     print "No new requests found. Exiting.";
     exit(0); 	
 } 
 else{
    &log(1, "Starting QB Data Extraction"); 
    
    foreach my $req_rid (@{$brequests}) {
        &log(1, "processing build request: $req_rid");                                                    
        ($err,$breq_data{$req_rid}) = &get_req_data($breq_qb_id, $req_rid, \%breq_data, \%breq_field_map);	
    }
    #foreach my $req_rid (@{$drequests}) {
        #&log(1, "processing deploy request: $req_rid");                                                    
        #($err,$dreq_data{$req_rid}) = &get_req_data($dreq_qb_id, $req_rid, \%dreq_data, \%dreq_field_map);
    #}
 
    #************************************
    # Data Structure should be populated by this point
    # The structure is a hash of build records referenced by the record id.
    # The field "pcomp_rec_ref" is a reference to a sub record of 
    # project component data.
    # The two key data structures to read include:
    #     %breq_data
    #     %dreq_data
    # The data structure is defined as:
    #        record --> subrecord --> subrecorddata 
    #	  (*req_data)	(pcomp)		field/value
    #					field/value
    #		     subrecord --> subrecorddata
    # 		     	(request)	field/value
    # 		     			field/value
    #
    
    #*****begin data processing********
    
    foreach my $record_id (keys %breq_data) {
        &log(1, "processing request id: $record_id");
        my $bf_record_ref;
        $bf_record_ref = filter_qb_to_bf($breq_data{$record_id});
        &insert_bf_data($bf_record_ref);
    }
 
    #*****done with data processing****
 
    if (!$err) {
        &log(1, "Data completed successfully");
    } else { 
        &log(0, "Errors Encountered");
    }
 }
}  
#**************************************
# check_for_request() - 
#
sub check_for_request(){
 my ($qb_id, $map_ref) = @_;
 my %map = %$map_ref;
 my $query_list = "";
 my ($status_id, $req_fid, $new_rid);
 my @results;
 my @rid_list;
 my $qdb = &make_qb();    	
 my $request_count=0;

 &log(1, "Checking for request") ;

 foreach my $key (sort keys %map) {
     $query_list = $key if ($map{$key} eq "Record ID");
     $status_id  = $key if ($map{$key} eq "Status");
 } 

 my $query = "{'" . $status_id . "'\.EX\.\"Requested\"}";	

 @results = $qdb->doQuery($qb_id, $query, "$query_list", 1, "sortorder-D");
 if ($qb->error()) {
     $error_tree{scalar(localtime())} = "error #". $qb->error(). ": ". $qb->errortext();
 }

 foreach my $rid_pair_ref (@results) {
     my %tmptable = %{$rid_pair_ref};
     foreach my $k1 (keys %tmptable) {
         push @rid_list, $tmptable{$k1};	
         $request_count++;
     }
 }

 &log(1, "Processing $request_count requests");
 
 $error_tree{status} = 1 if (keys %error_tree);
 
 return ($error_tree{status},\@rid_list);
}    
    
#**************************************
# get_req_data() - 
#
sub get_req_data(){
 my ($qb_id, $req_rid, $table_ref, $map_ref) = @_;
 my %table = %$table_ref;
 my %map = %$map_ref;
 my $query_list = "";
 my $req_fid;
 my $project_component;
 my @results;
 my $qdb = &make_qb();    	
 my %tmptable;
 
 &log(1, "Querying request data") ;

 foreach my $key (sort keys %map) {
     if ($query_list eq ""){$query_list .= "$key";}
     else {$query_list .= ".$key";}     
     $req_fid = $key if ($map{$key} eq "Record ID");
 } 
 
 my $query = "{'" . $req_fid . "'\.EX\.'" . $req_rid . "'}";	

 @results = $qdb->doQuery($qb_id, $query, "$query_list",1,"sortorder-D");
 if ($qb->error()) {
     $error_tree{scalar(localtime())} = "error #". $qb->error(). ": ". $qb->errortext();
 }
 my $tmp = $results[0];

 foreach my $record (@results) {
     foreach my $field (keys %$record) {
         $tmptable{$field} = $record->{$field};
     }
 }

 $table{"request_data_ref"} = \%tmptable;

 ($err, $table{"pcomp_data_ref"}) = &get_pcomp_data($pcomp_qb_id, $tmptable{"Project - Component"}, \%pcomp_data, \%pcomp_field_map);
 
 $error_tree{status} = 1 if (keys %error_tree);

 return ($error_tree{status}, \%table);
}    
    
#**************************************
# get_pcomp_data() - 
#
sub get_pcomp_data(){
 my ($qb_id, $pcomp_name, $table_ref, $map_ref) = @_;
 my %table = %$table_ref;
 my %map = %$map_ref;
 my $query_list = "";
 my ($pcomp_fid, $pcomp_rid);
 my @results;
 my $qdb = &make_qb();    	

 &log(1, "Querying Project Data") ;

 foreach my $key (sort keys %map) {
     if ($query_list eq ""){$query_list .= "$key";}
     else {$query_list .= ".$key";}     
     $pcomp_fid = $key if ($map{$key} eq "Project - Component");
     $pcomp_rid = $key if ($map{$key} eq "Record ID");
 } 
 
 my $query = "{'" . $pcomp_fid . "'\.EX\.'" . $pcomp_name . "'}"; 

 @results = $qdb->doQuery($qb_id, $query, "$query_list", 1, "sortorder-D");
 if ($qb->error()) {
     $error_tree{scalar(localtime())} = "error #". $qb->error(). ": ". $qb->errortext();
 }

 my $tmp = $results[0];
 
 foreach my $record (@results) {
     foreach my $field (keys %$record) {
         $table{$field} = $record->{$field};
     }
 }
 
 $error_tree{status} = 1 if (keys %error_tree);
 
 return ($error_tree{status}, \%table);
}  

#**************************************
# Helper routines
#************************************** 

#**************************************
# DIE_ERROR_TREE()
# output errors 
# 
sub die_error_tree {
 &log(1, "Encountered errors. Errors listed below:");
 foreach my $entry (keys %error_tree) {
     next if ($entry eq "status");
     &log(1, "$entry: $error_tree{$entry}");
 }
 &log(1, "exiting.");
 die;	
}

#**************************************
# LOG()
# log info 
# 
sub log{
 my ($msglevel,$msg) = @_;
 my @lt=localtime;
 my $time = sprintf("%d%d%d-%d%d",$lt[5]+1900,$lt[4]+1,$lt[3],$lt[2],$lt[1]);
 if ($msglevel <= $loglevel) {
   print "$time: $msg\n";
 }
 return;
}

#**************************************
# USAGE()
#        
sub usage{
print<<EOF;
 usage: qb_bf_bridge.pl [-h]
      	-h  --  help (this message)
EOF
}

#**************************************
# BuildForge Data Insertion Routines.
#**************************************

sub insert_bf_data{
 my $bf_record_ref = shift;
 my %bf_record = %{$bf_record_ref};
 
 &log(1, "Attempting to insert data into Buildforge") ;
 
 $api = BFI->login();

 print "Creating new QB BF Interface...\n";
 $bf = BFI->new(project=>$bf_record{"Project"},status=>"new");
 if (!defined $bf) {print "***ERROR - BF new project creation failure\n";
		   exit;
 }
 print "Test fail condition...\n";
 $bf_fail = BFI->new(project=>"BOGUS",status=>"bogus");
 if (defined $bf_fail) {print "***ERROR - BF created BOGUS project\n";}

 #Test fail condition for error checker
 print "Error Checker: Test fail condition...\n";
 $bf->report_error(0);

 print "\nGetting project info...\n";
 $istat = $bf->get_project();
 if ($istat != 0) {$bf->report_error($istat);
		  exit;}
 #Test fail condition for get_project
 print "Test fail condition...\n";
 $istat = $bf_fail->get_project();
 if ($istat != 0) {$bf_fail->report_error($istat);}

 print "\nSetting version number\n";
 $istat = $bf->set_version_number($bf_record{"Major Version"},$bf_record{"Minor Version"},$bf_record{"Revision"},$bf_record{"Build Number"});
 print "Test fail condition...\n";
 if ($istat !=0) {$bf->report_error($istat);}
 #Test fail conditions for set_version_number
 $istat = $bf->set_version_number("bogus",0,0,0);
 if ($istat !=0) {$bf->report_error($istat);}
 $istat = $bf->set_version_number(1,'none',0,0);
 if ($istat !=0) {$bf->report_error($istat);}
 $istat = $bf->set_version_number(1,0,3.1416,0);
 if ($istat !=0) {$bf->report_error($istat);}
 $istat = $bf->set_version_number(1,0,0,"bogus");
 if ($istat !=0) {$bf->report_error($istat);}

 print "\nSetting source label...\n";
 $istat = $bf->set_source_label($bf_record{"Source Label"});
 if ($istat !=0) {$bf->report_error($istat);}

 $ib = $bf->build();
 if (!defined $ib) {print "\n***ERROR - Build did not initiate\n";}
 else {print "\nBuild initiated - Build ID = $ib\n";}

}



#**************************************
# Quickbase Connection Routines.
#**************************************

#**************************************
# MAKE_QB() - Make the quickbase object
#           - borrowed from deploy-calendar code
#
sub make_qb {
 if (!defined($qb)){
     $qb = new HTTP::QuickBase;
     $qb->authenticate($CONFIG{'u'}, $CONFIG{'p'});
     &log(1, "Connecting as $CONFIG{'u'}") ;
     if ($qb->error()) {
        die("authentication error #". $qb->error(). ": ". $qb->errortext());
     }
 }	
 return $qb;
}

#**************************************
# INIT() - Set the quickbase connection parameters
#        - other config data is set in QuickBase.pm,
#          QBNIntranet.pm
#
sub init{
 my $qb_id = shift;
 &log(1, "Connecting to $qb_id") ;
 $CONFIG{'db'} = $qb_id;
 $CONFIG{'u'} 	= $USER;
 $CONFIG{'p'} 	= $PASS;
}

#**************************************
# Initialization Mapping.
#**************************************

#**************************************
# INIT_DATA_MAP()
# Field/value constants
#
sub init_data_map{
 %pcomp_field_map = (	 3 => "Record ID",
 			44 => "Project",
		    	53 => "Component",
		    	54 => "Project - Component",
		    	69 => "Architectural Domain",
		    	45 => "Info Web Page",
		    	75 => "Team Track Project",
		    	76 => "Major",
		    	77 => "Minor",
		    	78 => "Revision",
		    	79 => "Next Build",
		    	47 => "Source Control Path",
		    	74 => "SourceSafe Ini Folder",
		    	72 => "SourceSafe Ini Path",
		    	73 => "SourceSafe Project Root",
		   	68 => "Build Machine ID",
		   	46 => "Operating System",
		   	48 => "Build Instructions Path",
		   	71 => "Build Programs Path",
		   	49 => "Release Path",
		   	65 => "Notification"
	    	      );
 %breq_field_map  = ( 	71   => "Project - Component (ID)",
			130  => "Project - Component",
			73   => "Priority",
			74   => "Status",
			161  => "Status (for Display)",
			100  => "IsStatusCompleted",
			79   => "Date Needed",
			150  => "Major Version",
			151  => "Minor Version",
			152  => "Revision",
			153  => "Build Number",
			78   => "Version (Custom)",
			154  => "Version",
			116  => "Project Version",
			111  => "Source Label",
			102  => "Build Label",
			138  => "Project - Component - Build Label",
			115  => "Build Program Arguments",
			139  => "Start Date",
			140  => "Start Time",
			141  => "Stop Date",
			142  => "Stop Time",
			143  => "Duration",
			144  => "Previous Build Duration",
			147  => "Estimated Completion Time",
			145  => "Percent Complete",
			75   => "Special Instructions",
			132  => "Notes",
			160  => "Scheduled Build",
			3    => "Record ID",
			162  => "Related Component"		
		      );
 %dreq_field_map  = (   10 => "Environment",
 			11 => "Status",
 			6  => "Related Build Request",
 			13 => "Notes",
 			14 => "Project-Component - Build Label",
 			15 => "Change Request Number",
 			16 => "Deployer",
 			17 => "Build Request - Project - Component",
 			18 => "Build Request - Network Release Path",
 			19 => "Build Request - Project",
 			20 => "Build Request - TeamTrack Changes",
 			21 => "Build Request - Owner",
 			22 => "Requested Deploy Date",
 			23 => "Requested Deploy Tim",
 			24 => "Special Deployment Requirements",
 			25 => "Helpdesk Text",
 			26 => "Deploy Attempts",
 			27 => "Add Deploy Attempts",
 			28 => "Deployment Duration",
 			29 => "# of Deploy Attempts",
 			1  => "Date Created",
 			2  => "Date Modified",
 			3  => "Record ID#",
 			4  => "Record Owner",
 			5  => "Last Modified By");
 
 if ($debug) {
     &log(1, "setting field/values");
     print(Dumper(\%pcomp_field_map));
     print(Dumper(\%breq_field_map));
     print(Dumper(\%dreq_field_map));
     print "\n";
 }	
}

#**************************************
# FILTER_QB_TO_BF()
# Field/value constants
#
# Available variables:
#"Record ID", "Project", "Component",
#"Project - Component", "Architectural Domain", "Info Web Page", 
#"Team Track Project", "Major", "Minor", "Revision", "Next Build",
#"Source Control Path", "SourceSafe Ini Folder", "SourceSafe Ini Path", 
#"SourceSafe Project Root", "Build Machine ID", "Operating System",
#"Build Instructions Path", "Build Programs Path", "Release Path",
#"Notification"
#
sub filter_qb_to_bf{

 my $record = shift;
 my %bf_record;
 my %pcomp_record;
 my %breq_record;
 my %dreq_record;
  
 foreach my $subrecord_group (keys %$record) {
     #**********extract the pcomp data record
     if ($subrecord_group eq "pcomp_data_ref") {
         &log(1, "*****Retrieving project/component data*****") ;
         foreach my $sub_record_data_field (keys %{$record->{$subrecord_group}}) {
             &log(2, "$sub_record_data_field => $record->{$subrecord_group}{$sub_record_data_field}") ;
	     $pcomp_record{$sub_record_data_field} = $record->{$subrecord_group}{$sub_record_data_field};
         }    		
     }
     #**********extract the request data record
     if ($subrecord_group eq "request_data_ref") {
         &log(1, "*****Retrieving request data*****") ;
         foreach my $sub_record_data_field (keys %{$record->{$subrecord_group}}) {
             &log(2, "$sub_record_data_field => $record->{$subrecord_group}{$sub_record_data_field}") ;
	     $breq_record{$sub_record_data_field} = $record->{$subrecord_group}{$sub_record_data_field};
         }   		
     }
 }
     
 $bf_record{"Project"} 			= $pcomp_record{"Project - Component"};
 
 #resetting the project to test project:
 
 $bf_record{"Project"} 			= "QB BF Interface Test";
 
 $bf_record{"Major Version"} 		= $breq_record{"Major Version"};
 $bf_record{"Minor Version"} 		= $breq_record{"Minor Version"};
 $bf_record{"Revision"} 		= $breq_record{"Revision"};
 $bf_record{"Build Number"} 		= $breq_record{"Build Number"};
 $bf_record{"Build Program Arguments"} 	= $breq_record{"Build Program Arguments"};
 $bf_record{"Source Label"}		= $breq_record{"Source Label"};
 $bf_record{"Build Label"}		= $breq_record{"Build Label"};


 if ($debug) {
     &log(1, "mapping qb field/values to bf");
    # print(Dumper(\%pcomp_qb_bf_map));
    # print(Dumper(\%breq_qb_bf_map));
    # print(Dumper(\%dreq_qb_bf_map));
     print "\n";
 }	
 return (\%bf_record);
}




__END__
