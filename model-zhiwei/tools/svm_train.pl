#!/usr/bin/env perl

use warnings;
use strict;

binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

use Algorithm::SVM;
use Algorithm::SVM::DataSet;

my $svm = new Algorithm::SVM(Type   => 'C-SVC',
                             Kernel => 'radial');
#                             Gamma  => 64,
#                             C      => 8);
                        
my @training_data;
my %posnum = ('.' => 0, DET => 1, PRON => 2, ADP => 3, CONJ => 4, PRT => 5, NUM => 6, ADV => 7, VERB => 8, ADJ => 9, NOUN => 10, X => 11);

open (TRAINING, "<:utf8", $ARGV[0]) or die;
while (<TRAINING>) {
    chomp;
    my @items = split /\t/, $_;
    my $pos = shift @items;
    my $form = shift @items;
    my $count = shift @items;
    foreach my $c (1 .. $count) {
        my $ds = new Algorithm::SVM::DataSet(Label => $posnum{$pos}, Data  => \@items);
        push @training_data, $ds;
    }
}
close TRAINING;

print STDERR scalar @training_data;

$svm->train(@training_data);
$svm->save($ARGV[1]);
