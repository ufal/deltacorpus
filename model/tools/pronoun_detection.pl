#!/usr/bin/perl

use strict;
use warnings;

binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";

my @sentence;
my %s_count;
my %w_count;
my $total_count;

while (<>) {
    chomp;
    if ($_ =~ /^\d/) {
        my @items = split /\t/;
        if ($items[1] !~ /^\.,:;\?!$/) {
            push @sentence, lc($items[1]);
            $w_count{lc($items[1])}++;
            $total_count++;
            next;
        }
    }
    if (scalar @sentence > 2) {
        foreach my $i (0 .. $#sentence) {
            my $string = join(" ", @sentence[0 .. $i-1]);
            $string .= " _ ";
            $string .= join(" ", @sentence[$i+1 .. $#sentence]);
            $s_count{$string}{$sentence[$i]}++;
        }
    }
    @sentence = ();
}

my %p_count;
my %substituents;
foreach my $string (keys %s_count) {
    next if scalar keys %{$s_count{$string}} < 2;
    my $subst = join (" ", keys %{$s_count{$string}});
    foreach my $word (keys %{$s_count{$string}}) {
        $p_count{$word}++;
        $substituents{$word} .= " $subst";
    }
}

my @sorted = sort {$p_count{$b} <=> $p_count{$a}} keys %p_count;

foreach my $p (@sorted) {
    #print "$p\t$p_count{$p}\t$substituents{$p}\n";
    if ($w_count{$p} / $total_count > 0.001) {
        print "$p\t$p_count{$p}\n";
    }
}
