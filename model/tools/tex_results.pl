#!/usr/bin/env perl

use strict;
use warnings;

my @TRAIN;
my @TEST;
my $DIRECTORY = shift @ARGV;

my $was_separator = 0;
foreach my $language (@ARGV) {
    if ($language eq '-') {
        $was_separator = 1;
    }
    elsif (!$was_separator) {
        push @TRAIN, $language;
    }
    else {
        push @TEST, $language;
    }
}

print "  ";
foreach my $train (@TRAIN) {
    print " & $train";
}
print " & average\\\\\n";
my %average;
my %total;
foreach my $test (@TEST) {
    print "$test ";
    foreach my $train (@TRAIN) {
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
        my $number = defined $items[6] ? $items[3] : $items[2];
        if ($train ne $test) {
            $average{$test} += $number;
            $total{$test}++;
        }
        printf (" & %2.0f", $number);
    }
    if ($average{$test}) {
        $average{$test} /= $total{$test};
        printf (" & %2.0f", $average{$test});
    }
    else {
        print " & --";
    }
    print "\\\\\n";
}
