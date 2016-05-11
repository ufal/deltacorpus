#!/usr/bin/env perl

use strict;
use warnings;

binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";

my %tag;

open (DICTIONARY, "<:utf8", $ARGV[0]) or die;
while (<DICTIONARY>) {
    chomp;
    my @items = split /\t/;
    $tag{$items[1]} = $items[3];
}
close DICTIONARY;

my $oov = 0;
my $total = 0;

open(CONLL, "<:utf8", $ARGV[1]) or die;
while (<CONLL>) {
    chomp;
    if ($_ =~ /^\d/) {
        my @items = split /\t/, $_;
        my $t;
        $total++;
        if (!defined $tag{lc($items[1])}) {
            $oov++;
            if ($items[1] =~ /\d/) {
                $t = 'NUM';
            }
            elsif ($items[1] !~ /[[:alnum:]]/) {
                $t = 'PUNC';
            }
            else {
                $t = 'NOUN';
            }
        }
        else {
            $t = $tag{lc($items[1])};
        }
        print "$items[0]\t$items[1]\t$items[2]\t$t\n";
    }
    else {
        print "\n";
    }
}
close CONLL;
printf STDERR "OOV: %.3f%\n", ($oov / $total * 100);




