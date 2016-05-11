#!/usr/bin/perl

use strict;
use warnings;

binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";

while (<>) {
    chomp;
    my $line = $_;
    # tokenize
    $line =~ s/([^[:alnum:]])/ $1 /g;
    $line =~ s/\s+/ /g;
    $line =~ s/^\s+//g;
    $line =~ s/\s+$//g;
    my @tokens = split /\s/, $line;
    foreach my $i (0 .. $#tokens) {
        my $ord = $i + 1;
        print "$ord\t$tokens[$i]\n";
    }
    print "\n";
}

