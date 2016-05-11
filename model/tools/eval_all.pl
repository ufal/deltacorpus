#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long;

binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";

my $GOLD_DIRECTORY = '';
my $PREDICTED_DIRECTORY = '';
my $GOLD_SUFFIX = '.conll';
my $PREDICTED_SUFFIX = '.conll';
my $LANGUAGES = '';
my $DESCRIPTION = '';

GetOptions ("gold-dir=s"         => \$GOLD_DIRECTORY,
            "predicted-dir=s"    => \$PREDICTED_DIRECTORY,
            "gold-suffix=s"      => \$GOLD_SUFFIX,
            "predicted-suffix=s" => \$PREDICTED_SUFFIX,
            "languages=s"        => \$LANGUAGES,
            "description=s"      => \$DESCRIPTION,
           );

my @languages = split /\s/, $LANGUAGES;
my $sum_scores = 0;
my $num_languages = 0;

foreach my $lang (@languages) {

    my @gold;
    my @predicted;

    my $finished = 1;

    open (GOLD, "<:utf8", "$GOLD_DIRECTORY/$lang$GOLD_SUFFIX") or $finished = 0;
    if ($finished) {
        while (<GOLD>) {
            chomp;
            if ($_ =~ /^\d/) {
                my @items = split /\t/, $_;
                push @gold, $items[3];
            }
        }
        close GOLD;
    }

    open (PREDICTED, "<:utf8", "$PREDICTED_DIRECTORY/$lang$PREDICTED_SUFFIX") or $finished = 0;
    if ($finished) {
        while (<PREDICTED>) {
            chomp;
            if ($_ =~ /^\d/) {
                my @items = split /\t/, $_;
                push @predicted, $items[3];
            }
        }
        close PREDICTED;
    
        if ($#gold != $#predicted) {
            print STDERR "ERROR: Different size of gold and predicted data for language $lang (" . ($#gold + 1) . " vs. " . ($#predicted + 1) . ")\n";
            print " --";
        }
        else {
            $num_languages++;
            my $total = 0;
            my $correct = 0;
            foreach my $i (0 .. $#gold) {
                $total++;
                $correct++ if $gold[$i] eq $predicted[$i];
            }
            my $score = 100 * $correct / $total;
            $sum_scores += $score;
            printf (" %.0f", $score);
        }
    }
    else {
        print " --";
    }
}

printf ("  %.1f  %s\n", ($sum_scores / $num_languages), $DESCRIPTION);


