#!/usr/bin/env perl

use warnings;
use strict;

binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

use Algorithm::SVM;
use Algorithm::SVM::DataSet;

my $svm = new Algorithm::SVM(Model => $ARGV[1]);
my @num2pos = qw(. DET PRON ADP CONJ PRT NUM ADV VERB ADJ NOUN X);

my $all;
my $correct;
my $nouns_count;

open(TESTING, "<:utf8", $ARGV[0]) or die;
while (<TESTING>) {
    chomp;
    my @items = split /\t/, $_;
    my $pos = shift @items;
    my $form = shift @items;
    my $count = shift @items;
    my $ds = new Algorithm::SVM::DataSet(Label => 0, Data  => \@items);
    my $predicted = $num2pos[$svm->predict($ds)];
    $all += $count;
    $correct += $count if $predicted eq $pos;
    $nouns_count += $count if $pos eq 'NOUN';
    print "$pos\t$form\t$count\t$predicted\n";
}
close TESTING;

my $accuracy = 100 * $correct / $all;
my $baseline = 100 * $nouns_count / $all;
print STDERR "$ARGV[1]\t$ARGV[0]\tAccuracy: $accuracy\t(noun baseline: $baseline)\n";

