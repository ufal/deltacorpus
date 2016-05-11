#!/usr/bin/env perl

use strict;
use warnings;

binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";

my @gold;
my @predicted;

open (GOLD, "<:utf8", $ARGV[0]) or die;
while (<GOLD>) {
    chomp;
    if ($_ =~ /^\d/) {
        my @items = split /\t/, $_;
        push @gold, $items[3];
    }
}
close GOLD;

open (PREDICTED, "<:utf8", $ARGV[1]) or die;
while (<PREDICTED>) {
    chomp;
    if ($_ =~ /^\d/) {
        my @items = split /\t/, $_;
        push @predicted, $items[3];
    }
}

if ($#gold != $#predicted) {
    print STDERR "ERROR: Different size of gold and predicted data (" . ($#gold + 1) . " vs. " . ($#predicted + 1) . ")\n";
}
else {
    my $total = 0;
    my $correct = 0;
    foreach my $i (0 .. $#gold) {
        $total++;
        $correct++ if $gold[$i] eq $predicted[$i];
        #print "$gold[$i] - $predicted[$i]\n";
    }
    printf (" %.0f", (100 * $correct / $total));
}

