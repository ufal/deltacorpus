#!/usr/bin/perl

use warnings;
use strict;

binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

use List::Util qw/max sum/;

my @weights = (1,1,1,1,1);

sub knn_classify {
    my ($target, $recordset, $labels, $words, $counts, $k) = @_;

    my $rows      = scalar @{$recordset};
    my $columns   = scalar @{$recordset->[0]};
    my $distances = {};

    foreach my $i (0 .. $rows-1) {
        my $value = sum(map { (($target->[$_] - $recordset->[$i][$_]) * $weights[$_]) ** 2 } (0 .. $#weights));
        $distances->{$i} = $value ** 0.5;
    }

    my %nearest;
    my @nearest_pos;
    my $nearest_count = 0;
    while ($nearest_count < $k) {
        my $min = 1000000;
        my $min_index;
        foreach my $i (0 .. $rows - 1) {
            if (!defined $nearest{$i} && $distances->{$i} < $min) {
                $min = $distances->{$i};
                $min_index = $i;
            }
        }
        $nearest{$min_index} = 1;
        push @nearest_pos, $labels->[$min_index];
        $nearest_count += $counts->[$min_index];
    }
    return @nearest_pos;
}

my @training_features;
my @training_labels;
my @training_words;
my @training_counts;

open (TRAINING, "<:utf8", $ARGV[0]) or die;
while (<TRAINING>) {
    chomp;
    my @items = split /\t/, $_;
    my $pos = shift @items;
    my $form = shift @items;
    my $count = shift @items;
    push @training_features, \@items;
    push @training_labels, $pos;
    push @training_words, $form;
    push @training_counts, $count;
}
close TRAINING;

my $correct = 0;
my $nouns_count = 0;
my $all = 0;

my %wordclass;
my $num_classes = 0;
open (WC, "<:utf8", $ARGV[2]) or die;
while (<WC>) {
    chomp;
    my ($word, $class) = split /\t/, $_;
    $wordclass{lc($word)} = $class;
    $num_classes = $class if $class > $num_classes;
}
my @pos_for_wc;

open(TESTING, "<:utf8", $ARGV[1]) or die;
while (<TESTING>) {
    chomp;
    my @items = split /\t/, $_;
    my $pos = shift @items;
    my $form = shift @items;
    my $count = shift @items;
    my $wc = defined $wordclass{lc($form)} ? $wordclass{lc($form)} : $num_classes;
    my @best_labels = knn_classify(\@items, \@training_features, \@training_labels, \@training_words, \@training_counts, 100);
    foreach my $label (@best_labels) {
        $pos_for_wc[$wc]{$label} += $count;
    }
}
close TESTING;

my @best_label;
foreach my $wc (0 .. $num_classes) {
    my ($label) = sort {$pos_for_wc[$wc]{$b} <=> $pos_for_wc[$wc]{$a}} keys %{$pos_for_wc[$wc]};
    $best_label[$wc] = $label;
}

open(TESTING, "<:utf8", $ARGV[1]) or die;
while (<TESTING>) {
    chomp;
    my @items = split /\t/, $_;
    my $pos = shift @items;
    my $form = shift @items;
    my $count = shift @items;
    my $wc = defined $wordclass{lc($form)} ? $wordclass{lc($form)} : $num_classes;
    $all += $count;
    $correct += $count if $best_label[$wc] eq $pos;
    $nouns_count += $count if $pos eq 'NOUN';
    print "$pos\t$form\t$wc\t$count\t$best_label[$wc]\n";
}
close TESTING;

my $accuracy = 100 * $correct / $all;
my $baseline = 100 * $nouns_count / $all;
print STDERR "$ARGV[1]\tAccuracy: $accuracy\t(noun baseline: $baseline)\n";

