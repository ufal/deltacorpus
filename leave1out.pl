#!/usr/bin/env perl

use strict;
use warnings;

my $srcpath = 'data/features/train';
my $tgtpath = 'data/features/train_leave1out';
if($ARGV[0] eq 'hamledt')
{
    shift(@ARGV);
    $srcpath = 'data/features/htrain';
    $tgtpath = 'data/features/htrain_leave1out';
}
my @languages = @ARGV;

system "mkdir -p $tgtpath";
foreach my $lang1 (@languages) {
    print STDERR "$lang1:";
    system "rm -f $tgtpath/$lang1.feat";
    foreach my $lang2 (@languages) {
        if (substr($lang1, 0, 2) ne substr($lang2, 0, 2)) {
            print STDERR " $lang2";
            system "cat $srcpath/$lang2.feat | head -30000 >> $tgtpath/$lang1.feat";
        }
    }
    print STDERR "\n";
}
