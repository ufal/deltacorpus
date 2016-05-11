#!/usr/bin/env perl

use strict;
use warnings;

binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";

while (<>) {
    chomp;
    my @items = split /\t/, $_;
    if ($items[$#items] && $items[$#items] eq '*') {
        if ($items[0] =~ /^[^[:alnum:]]*$/) {
            $items[$#items-1] = '.';
        }
        else {
            $items[$#items-1] = 'NOUN';
        }
    }
    print join "\t", @items;
    print "\n";
}
