#!/usr/bin/perl

use strict;
use warnings;
use utf8;

binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";

my $MAX_TOKENS = 1000000;
my $token_cnt = 0;

while (<>) {
    chomp;
    my $line = $_;
    # tokenize
    $line =~ s/(\w+)/ $1 /g;
    $line =~ s/([^\s\w]+)/ $1 /g;
    $line =~ s/([^\s\w\d])/ $1 /g;
    $line =~ s/\s+/ /g;
    $line =~ s/^\s+//g;
    $line =~ s/\s+$//g;
    my @tokens = split /\s/, $line;
    foreach my $i (0 .. $#tokens) {
        my $ord = $i + 1;
        print "$ord\t$tokens[$i]\t_\t_\t_\t_\t_\n";
        $token_cnt++;
    }
    print "\n";
    last if $token_cnt > $MAX_TOKENS;
}

