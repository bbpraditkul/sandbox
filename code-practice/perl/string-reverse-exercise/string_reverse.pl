#!/usr/bin/env perl -w
use strict;

#The following is one solution to a typical interview question that I like to ask:
#Question:
#Write a program that reverses strings in a file, line by line, from top to bottom
#For example, given a file that has:
#  abc def
#  12 23 34
#  foobar
#The script would return:
#  fed cba
#  43 32 21
#  raboof
#

my $file = shift;

open (FH, "< $file");

my @arr = ();

while (<FH>) {
    if (/^(\S+.*)/){
        my $line = $1;
        push (@arr, $line);
    }
}

foreach my $val (@arr) {
    print "original: $val\n";
    print "reversed: ", &reverse_arr($val), "\n";
}

sub reverse_arr($) {
    my $my_line = shift;
    my $my_reversed_line = "";
    my @arr2 = split //, $my_line;

    for my $t (reverse @arr2) {
        $my_reversed_line .= "$t";
        }

    return $my_reversed_line;
}

__END__
