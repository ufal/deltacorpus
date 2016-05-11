#!/usr/bin/env perl

use strict;
use warnings;

binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";

my %count;

my %fc = (bg => 10850, ca => 8518, de => 11129, el => 10028, hi => 6758, hu => 15624, tr => 13193);

while (<>) {
    chomp;
    if ($_ =~ /^\t/) {
        my @items = split /\t/, $_;
        #$count{$items[1]}++;
        $count{$items[1]} += $items[4];
    }
}

#foreach my $lang (keys %count) {
#    $count{$lang} /= $fc{$lang};
#}

my @sorted = sort {$count{$b} <=> $count{$a}} keys %count;
foreach my $lang (@sorted) {
    printf ("%s: %.5f\t", $lang, $count{$lang});
    #print STDERR "$lang: $count{$lang}\t";
}
print "\n\n";
