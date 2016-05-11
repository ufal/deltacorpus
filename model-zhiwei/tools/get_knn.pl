#!/usr/bin/perl

use warnings;
use strict;

binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

use List::Util qw/max sum/;

my @weights = (1,1,1,1,1,5,5,1,1);
my $K = 20;

my @training_features;
my @training_labels;
my @training_words;
my @training_counts;
my @training_langcodes;

open (TRAINING, "<:utf8", $ARGV[0]) or die;
while (<TRAINING>) {
    chomp;
    my @items = split /\t/, $_;
    my $pos = shift @items;
    my $langcode = shift @items; # TOHLE U POUZITI NA STARYCH DATECH ZAKOMENTOVAT
    my $form = shift @items;
    my $count = shift @items;
    push @training_features, \@items;
    push @training_labels, $pos;
    push @training_langcodes, $langcode; # TOHLE U POUZITI NA STARYCH DATECH ZAKOMENTOVAT
    push @training_words, $form;
    push @training_counts, $count;
}
close TRAINING;

my $correct = 0;
my $nouns_count = 0;
my $all = 0;

open(LOG, ">:utf8", $ARGV[2]) or die;
open(TESTING, "<:utf8", $ARGV[1]) or die;
while (<TESTING>) {
    chomp;
    my @items = split /\t/, $_;
    my $pos = shift @items;
    my $langcode = shift @items;
    my $form = shift @items;
    my $count = shift @items;
    
    my $distances = {};

    foreach my $i (0 .. $#training_features) {
        my $value = sum(map { ((($items[$_] || 0) - ($training_features[$i][$_] || 0)) * $weights[$_]) ** 2 } (0 .. $#weights));
        $distances->{$i} = $value ** 0.5;
    }

    print LOG "$form ($count)\n";    

    my %nearest;
    my %nearest_pos;
    my $nearest_instance_count = 0;
    my $nearest_total_count = 0;
    while ($nearest_instance_count < $K) {
        my $min = 1000000;
        my $min_index;
        foreach my $i (0 .. $#training_features - 1) {
            if (!defined $nearest{$i} && $distances->{$i} <= $min) {
                $min = $distances->{$i};
                $min_index = $i;
            }
        }
        $nearest{$min_index} = 1;
        $nearest_instance_count++;
        $nearest_total_count += $training_counts[$min_index];
        $nearest_pos{$training_labels[$min_index]} += $training_counts[$min_index];
        print LOG "\t$training_langcodes[$min_index]\t$training_words[$min_index]\t$training_labels[$min_index]\t$training_counts[$min_index]\n";
    }

    print "$form\t" . (1000 * $count);
    foreach my $p (keys %nearest_pos) {
        printf ("\t%s\t%.0f", $p, ($nearest_pos{$p} / $nearest_total_count * $count * 1000));
    }
    print "\n";
}
close TESTING;
close LOG;

