#!/usr/bin/env perl

use strict;
use warnings;

my $collection = 'ud';
if($ARGV[0] eq 'hamledt')
{
    shift(@ARGV);
    $collection = 'hamledt2';
}
my @languages = @ARGV;

my @slavic = qw(be bg cs cu hr mk pl sl sk sr ru uk);
my @germanic = qw(da de en is nl no sv);
my @romance = qw(ca es fr gl it pt ro);
my @indoeur = (@slavic, @germanic, @romance, qw(el fa ga hi la));
my @agglut = qw(et eu fi hu tr);
my @c7 = qw(bg ca de el hi hu tr); # We defined this for HamleDT 2.0. UD 1.2 does not have ca and tr.

foreach my $lang1 (@languages) {
    # Language without treebank extension, e.g. 'fi' instead of 'fi_ftb'.
    my $l1 = $lang1;
    $l1 =~ s/_.*//;
    my $tgtpath = "data/$collection/$lang1/multitrain";
    system "rm -rf $tgtpath";
    system "mkdir -p $tgtpath";
    print STDERR "$lang1:";
    foreach my $lang2 (@languages) {
        my $l2 = $lang2;
        $l2 =~ s/_.*//;
        if ($l1 ne $l2) {
            print STDERR " $lang2";
            system "cat data/$collection/$lang2/train/$lang2.feat | head -30000 >> $tgtpath/all.feat";
            system "cat data/$collection/$lang2/train/$lang2.feat | head -30000 >> $tgtpath/csla.feat" if grep {$_ eq $l2} @slavic;
            system "cat data/$collection/$lang2/train/$lang2.feat | head -30000 >> $tgtpath/cger.feat" if grep {$_ eq $l2} @germanic;
            system "cat data/$collection/$lang2/train/$lang2.feat | head -30000 >> $tgtpath/crom.feat" if grep {$_ eq $l2} @romance;
            system "cat data/$collection/$lang2/train/$lang2.feat | head -30000 >> $tgtpath/cine.feat" if grep {$_ eq $l2} @indoeur;
            system "cat data/$collection/$lang2/train/$lang2.feat | head -30000 >> $tgtpath/cagl.feat" if grep {$_ eq $l2} @agglut;
            system "cat data/$collection/$lang2/train/$lang2.feat | head -30000 >> $tgtpath/c7.feat"   if grep {$_ eq $l2} @c7;
        }
    }
    print STDERR "\n";
}
