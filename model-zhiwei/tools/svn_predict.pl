#!/usr/bin/perl

use warnings;
use strict;

binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";

use Algorithm::SVM;
use Algorithm::SVM::DataSet;

my $svm = new Algorithm::SVM(Type   => 'C-SVC',
                            Kernel => 'radial');
my @training_data;

open (TRAINING, "<:utf8", $ARGV[0]) or die;
while (<TRAINING>) {
    chomp;
    my @items = split /\t/, $_;
    my $pos = shift @items;
    my $form = shift @items;
    my $count = shift @items;
    $ds = new Algorithm::SVM::DataSet(Label => $pos, Data  => \@items);
    foreach my $c (1 .. $count) {
        push @training_data, $ds;
    }
}
close TRAINING;

$svm->train(@training_data);
$svm->save($ARGV[1]);
