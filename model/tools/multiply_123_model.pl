#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;

binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";

my $MULT = 1;
GetOptions ("mult=i" => \$MULT);

while (<>) {
    chomp;
    if ($_ !~ /^%%/) {
        my @items = split /\t/, $_;
        if ($items[$#items] =~ /^\d+$/) {
            $items[$#items] *= $MULT;
        }
        print join("\t", @items);
    }
    else {
        print $_;
    }
    print "\n";
}



