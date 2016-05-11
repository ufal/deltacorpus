#!/usr/bin/perl

use strict;
use warnings;

binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";

while (<>) {
    chomp;
    if ($_ =~ /^\d+\t/ || $_ =~ /^$/) {
        print "$_\n";
    }
}




