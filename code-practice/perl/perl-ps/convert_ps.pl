#!/usr/bin/perl -w

use Data::Dumper;
use strict;
use warnings;
use ProcessObject;

my $file = shift;
my %obj_catalog;  #objects ref'ed by pid
my %format = (pid  => 5,
	      tty  => 8,
	      stat => 6,
	      time => 4,
              nest => 0,
   	      conn => 0
             );  #misc data to help dynamically format the output

#***********************************
# Open source file and
# Parse all source data 
# Sample line:
# F   UID   PID  PPID PRI  NI    VSZ   RSS WCHAN  STAT TTY        TIME COMMAND
# 4     0     1     0  16   0   1476   500 -      S    ?          0:00 init [3]  
#
open (FH, "< $file") || die "Unable to open $file: $!\n";

while (<FH>) {
    my ($pid,$ppid,$cmd,$stat,$tty,$time) = (0,0,"","","","0:00");
    if (/^\w+\s+	#F
       	  \d+\s+  	#UID
	 (\d+)\s+ 	#PID
	 (\d+)\s+ 	#PPID
 	  \S+\s+  	#PRI
 	  \S+\s+  	#NI
 	  \w+\s+  	#VSZ
 	  \w+\s+  	#RSS
 	  \S+\s+  	#WCHAN
 	 (\S+)\s+  	#STAT
 	 (\S+)\s+  	#TTY
 	 (\d+:\d+)\s+  	#TIME
	 (.*)     	#COMMAND
         /x) {
        ($pid,$ppid,$stat,$tty,$time,$cmd) = ($1,$2,$3,$4,$5,$6);
    }

    next if ($pid == 0); # ignore the initial case

    #******************************* 
    # instantiate the process object
    # and keep track of it.
    #
    my $process_obj = new ProcessObject ($pid,$ppid,$stat,$tty,$time,$cmd);

    $obj_catalog{$pid} = $process_obj;

    #*******************************
    # determine if our initial 
    # spacing for the header is
    # enough.  Reset to the max 
    # length as appropriate
    #
    $format{pid}  = length($pid)  if (length($pid)  > $format{pid});
    $format{stat} = length($stat) if (length($stat) > $format{stat});
    $format{tty}  = length($tty)  if (length($tty)  > $format{tty});
    $format{time} = length($time) if (length($time) > $format{time});
    
    #*******************************
    # if the object is a child of a
    # parent process, store it as 
    # the parent object's list of 
    # associated child objects
    #  
    if ($ppid > 2) {
        my $parent_obj = $obj_catalog{$ppid};
        my $child_objs = $parent_obj->getChildObjects();
 
        push (@$child_objs, $process_obj);
 
        $parent_obj->setChildObjects($child_objs);
    }
}

close (FH);

#***********************************
# start the moment of truth, output!
# Traverse the object catalog for
# parent objects. For each parent,
# recursively iterate through all
# child objects via 'checkObject()'
#
print printHeader();

foreach my $ppid (sort { $a <=> $b } keys %obj_catalog) {
    my $parent_obj = $obj_catalog{$ppid};
    if ($parent_obj->getParentID < 2) {
        checkObject($parent_obj, 'parent', 0, 0);
    }
}

#***********************************
# checkID: This routine retrieves
# all descendent objects for the
# parent object.  The purpose of the
# "spacer" is to visually identify 
# the nest level in the output
#
sub checkObject {
    my ($object,$type,$spacer,$conn) = @_; 
    my $child_objs = $object->getChildObjects();
    my $array_size = 0;
    my $last_child_obj = pop @$child_objs;
    $array_size = @$child_objs if defined @$child_objs;;
    print "array is now $array_size:";
    if (defined $child_objs && $array_size > 0 && $format{nest} > 0){
        $conn++;
    }

print $conn;

    printFormattedLine ($object->getProcessID,
			$object->getTTY,
			$object->getStat,
			$object->getTime,
			$object->getCommand,
			$type,
			$spacer,
		       );
    $spacer+=4 if ($type eq 'child');

    foreach my $child_obj (@$child_objs) {
        $format{nest}++;
        checkObject($child_obj, 'child', $spacer, $conn);
        $format{nest}--;
    } 
    if (defined $last_child_obj) {
        $format{nest}++;
        
        checkObject($last_child_obj, 'child', $spacer, $conn);
        $format{nest}--;
    }
    $conn--;
}

sub help {
    return sprintf ("\nusage: ./convert_ps.pl <file_to_import>\n\n");
}

sub printHeader {
    return sprintf("%$format{pid}s ".
		   "%-$format{tty}s ".
		   "%-$format{stat}s ".
		   "%-$format{time}s ".
		   "%-s\n", 
		   'PID', 'TTY', 'STAT', 'TIME', 'COMMAND');
}

sub printFormattedLine {
    my ($pid, $tty, $stat, $time, $command, $type, $spacer) = @_;
    printf("%$format{pid}s ".
	   "%-$format{tty}s ".
	   "%-$format{stat}s ".
	   "%-$format{time}s ",
           $pid, $tty, $stat, $time
  	  );
    print " ", " "x$spacer, "\\_ " if ($type eq 'child');
    printf ("%-s\n", $command); 
    
}

