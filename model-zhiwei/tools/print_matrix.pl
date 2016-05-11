#!/usr/bin/env perl

use strict;
use warnings;

my @TRAIN = qw(bg ca de el hi hu it pt ru sv ta tr c4 c7);
my @TEST = qw(bg bn ca cs da de el es en et eu fa fi hi hu it la nl pt ro ru sk sl sv ta te tr);

my $DIRECTORY = $ARGV[0];

print "  ";
foreach my $test (@TEST) {
    print " $test";
}
print "\n";
foreach my $train (@TRAIN) {
    print "$train";
    foreach my $test (@TEST) {
        my $not_found = 0;
        my $line;
        open (RESULTS, "<:utf8", "$DIRECTORY/$train-$test.results") or $not_found = 1;
        if (!$not_found) {
            $line = <RESULTS>;
            close RESULTS;
        }
        if (!defined $line) {
            print " --";
            next;
        }
        my @items = split /\s/, $line;
        printf (" %2.0f", defined $items[6] ? $items[3] : $items[2]);
    }
    print "\n";
}
