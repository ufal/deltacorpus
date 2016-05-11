#!/usr/bin/env perl

use strict;
use warnings;

binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";

while (<>) {
    chomp;
    my $out = "";
    if ($_ =~ /\d/) {
        my @items = split /\t/;
        $items[1] = lc($items[1]);
        $out = join("\t", @items);
    }
    print "$out\n";
}
   
