#!/usr/bin/perl

use warnings;
use strict;

use Getopt::Long;

binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

use List::Util qw/max sum/;

my $FEATURES = "1,2,3,4,5,6,7,8,9,10,11"; 
my $WEIGHTS = "1,1,1,1,1,5,5,1,1,1,1";
my $K = 10;
my $VERBOSE = 0;
my $TRAINING_FILE = '';
my $TESTING_FILE = '';
my $COUNT_TOKENS = 0;

GetOptions ("features=s"   => \$FEATURES,
            "weights=s"    => \$WEIGHTS,
            "verbose=i"    => \$VERBOSE,
            "k=i"          => \$K,
            "train=s"      => \$TRAINING_FILE,
            "test=s"       => \$TESTING_FILE,
            "count-tokens" => \$COUNT_TOKENS,
           );

my @features = split /,/, $FEATURES;
my @weights = split /,/, $WEIGHTS;

if (scalar @features != scalar @weights) {
    print STDERR "ERROR: The number of features is not equal to the number of weights.\n";
    exit;
}

my @training_features;
my @training_labels;
my @training_langcodes;
my @training_words;
my @training_counts;

open (TRAINING, "<:utf8", $TRAINING_FILE) or die;
while (<TRAINING>) {
    chomp;
    my @items = split /\t/, $_;
    my $pos = shift @items;
    my $langcode = shift @items;
    my $form = shift @items;
    my $count = shift @items;
    my @feat;
    foreach my $f (@features) {
        push @feat, $items[$f-1];
    }
    push @training_features, \@feat;
    push @training_labels, $pos;
    push @training_langcodes, $langcode;
    push @training_words, $form;
    push @training_counts, $count;
}
close TRAINING;

#my $correct = 0;
#my $nouns_count = 0;
#my $all = 0;

open(TESTING, "<:utf8", $TESTING_FILE) or die;
while (<TESTING>) {
    chomp;
    my @items = split /\t/, $_;
    my $pos = shift @items;
    my $langcode = shift @items;
    my $form = shift @items;
    my $count = shift @items;
    my @test_features;
    foreach my $f (@features) {
        push @test_features, $items[$f-1];
    }

    my $distances = {};

    foreach my $i (0 .. $#training_features) {
        my $value = sum(map {((($test_features[$_] || 0) - ($training_features[$i][$_] || 0)) * $weights[$_]) ** 2} (0 .. $#weights));
        $distances->{$i} = $value ** 0.5;
    }
    print STDERR "$form ($count)\n";    

    my %nearest;
    my %nearest_pos;
    my $nearest_count = 0;
    while ($nearest_count < $K) {
        my $min = 1000000;
        my $min_index;
        foreach my $i (0 .. $#training_features) {
            if (!defined $nearest{$i} && $distances->{$i} <= $min) {
                $min = $distances->{$i};
                $min_index = $i;
            }
        }
        $nearest{$min_index} = 1;
        if ($COUNT_TOKENS) {
            $nearest_count += $training_counts[$min_index];
        }
        else {
            $nearest_count++;
        }
        $nearest_pos{$training_labels[$min_index]} += $training_counts[$min_index];
        print STDERR "\t$training_langcodes[$min_index]\t$training_words[$min_index]\t$training_labels[$min_index]\t$training_counts[$min_index]\t";
        if ($VERBOSE) {
            foreach my $i (0 .. $#test_features) {
                printf STDERR "%d|%.2f|%.2f ", $i, $training_features[$min_index][$i], $test_features[$i];
            }
        }
        print STDERR "\n";
    }
    my @best_labels = sort {$nearest_pos{$b} <=> $nearest_pos{$a}} keys %nearest_pos;
    
    print "$pos\t$form\t$count\t$best_labels[0]\t";
    foreach my $i (0 .. $#best_labels) {
        my $p = $nearest_pos{$best_labels[$i]} / $nearest_count;
        printf ("%s=%.2f", $best_labels[$i], $p);
        print "," if $i < $#best_labels;
    }
    print "\n";

#    $all += $count;
#    $correct += $count if $best_label eq $pos;
#    $nouns_count += $count if $pos eq 'NOUN';
}
close TESTING;

#my $accuracy = 100 * $correct / $all;
#my $baseline = 100 * $nouns_count / $all;
#print STDERR "$ARGV[0]\t$ARGV[1]\tAccuracy: $accuracy\t(noun baseline: $baseline)\n";

