#!/usr/bin/env perl

use strict;
use warnings;

my @languages = @ARGV;

foreach my $lang1 (@languages) {
    print STDERR "$lang1:";
    system "rm -f data/features/train_leave1out/$lang1.feat";
    foreach my $lang2 (@languages) {
        if (substr($lang1, 0, 2) ne substr($lang2, 0, 2)) {
            print STDERR " $lang2";
            system "cat data/features/train/$lang2.feat | head -30000 >> data/features/train_leave1out/$lang1.feat";
        }
    }
    print STDERR "\n";
}

