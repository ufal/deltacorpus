#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";

my %tag;
open(PREDICTED, "<:utf8", $ARGV[1]) or die;
while (<PREDICTED>) {
    chomp;
    my ($word, $gold, $nothing, $pred) = split /\t/, $_;
    $tag{$word} = $pred;
}
close PREDICTED;

my %is_oov;
my $correct = 0;
my $total = 0;
open(INPUT, "<:utf8", $ARGV[0]) or die;
while(<INPUT>) {
    chomp;
    if ($_ =~ /^\d/) {
        my ($ord, $form, $lemma, $gold_pos, $pos2) = split /\t/, $_;
        if (!defined $tag{$form}) {
            if (defined $tag{lc($form)}) {
                $tag{$form} = $tag{lc($form)};
            }
            elsif ($form =~ /^[^\w\d]+$/) {
                $tag{$form} = 'PUNCT';
                $is_oov{$form} = 1;
            }
            elsif ($form =~ /^[\d,\.]+$/) {
                $tag{$form} = 'NUM';
                $is_oov{$form} = 1;
            }
            else {
                $tag{$form} = 'NOUN';
                $is_oov{$form} = 1;
            }
        }
        my $oov = $is_oov{$form} ? 'oov' : '';
        print ("$ord\t$form\t_\t$gold_pos\t$tag{$form}\t$oov\n");
        $total++;
        $correct++ if $gold_pos eq $tag{$form};
    }
    else {
        print "\n";
    }
}
close INPUT;
printf STDERR ("Score: %.2f\n", 100 * $correct / $total);
