#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use Getopt::Long;

binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";

my $TEST_FILE = '';
my $DICT_FILE = '';
my $ITERATIONS = 100;
my $ALPHA = 0.1;
my $BETA = 0.1;
my $CANDIDATE_LIMIT = 0.5;

GetOptions ("test=s"       => \$TEST_FILE,
            "dict=s"       => \$DICT_FILE,
            "iterations=i" => \$ITERATIONS,
            "cand-limit=f" => \$CANDIDATE_LIMIT,
            "alpha=f"      => \$ALPHA,
            "beta=f"       => \$BETA,
        );

my @word;
my @gold_pos;
my $sent_num = 0;
my @pos;
my @candidates;

my %bigram_count;
my %emission_count;

my %dict;
open (DICT, "<:utf8", $DICT_FILE) or die;
while (<DICT>) {
    chomp;
    my @items = split /\t/, $_;
    my @possible_tag_prob = split /,/, $items[4];
    my @possible_tags;
    my $limit = $CANDIDATE_LIMIT;
    foreach my $p (@possible_tag_prob) {
        my ($t, $v) = split /=/, $p;
        $limit -= $v;
        push @possible_tags, $t;
        last if $limit <= 0;
    }
    $dict{$items[1]} = \@possible_tags;
}
close DICT;

my %is_word;
open (TEST, "<:utf8", $TEST_FILE) or die;
while (<TEST>) {
    chomp;
    if ($_ =~ /^\d/) {
        my @items = split /\t/, $_;
        my $lcword = lc($items[1]);
        $word[$sent_num][$items[0]] = $lcword;
        $gold_pos[$sent_num][$items[0]] = $items[3];
        $is_word{$lcword} = 1;
        if ($dict{$lcword}) {
            my @c = @{$dict{$lcword}};
            $candidates[$sent_num][$items[0]] = [@c];
        }
        else {
            my @c = ('NOUN', 'ADJ', 'VERB', 'ADV');
            $candidates[$sent_num][$items[0]] = \@c;
        }
    }
    else {
        $sent_num++;
    }
}
close TEST;

my $W = scalar keys %is_word;
my $T = 12;

# random initialization
foreach my $s (0 .. $#word) {
    foreach my $w (1 .. $#{$word[$s]}) {
        $pos[$s][$w] = $candidates[$s][$w][int(rand($#{$candidates[$s][$w]} + 1))];
    }
    $pos[$s][0] = '<s>';
    $pos[$s][$#{$word[$s]}+1] = '<s>';

}

# initial counts
foreach my $s (0 .. $#word) {
    foreach my $w (1 .. $#{$word[$s]} + 1) {
        if ($w != $#{$word[$s]} + 1) {
            $emission_count{$pos[$s][$w]}{$word[$s][$w]}++;
            $emission_count{$pos[$s][$w]}{'<all>'}++;
        }
        $bigram_count{$pos[$s][$w-1]}{$pos[$s][$w]}++;
        $bigram_count{$pos[$s][$w-1]}{'<all>'}++;
    }
}

# sampling
foreach my $iter (1 .. $ITERATIONS) {
    print STDERR "$iter ";
    foreach my $s (0 .. $#word) {
        foreach my $w (1 .. $#{$word[$s]}) {
            
            # subtract counts
            $emission_count{$pos[$s][$w]}{$word[$s][$w]}--;
            $emission_count{$pos[$s][$w]}{'<all>'}--;
            $bigram_count{$pos[$s][$w-1]}{$pos[$s][$w]}--;
            $bigram_count{$pos[$s][$w-1]}{'<all>'}--;
            $bigram_count{$pos[$s][$w]}{$pos[$s][$w+1]}--;
            $bigram_count{$pos[$s][$w]}{'<all>'}--;

            # compute weights of possible tags
            my @weight;
            my $sum_weight = 0;
            foreach my $i (0 .. $#{$candidates[$s][$w]}) {
                my $p = $dict{$word[$s][$w]}[$i];
                $weight[$i] =  ($ALPHA + ($emission_count{$p}{$word[$s][$w]} || 0)) / ($ALPHA * $W + ($emission_count{$p}{'<all>'} || 0));
                $weight[$i] *= ($BETA + ($bigram_count{$pos[$s][$w-1]}{$p} || 0)) / ($BETA * $T + ($bigram_count{$pos[$s][$w-1]}{'<all>'} || 0));
                $weight[$i] *= ($BETA + ($bigram_count{$p}{$pos[$s][$w+1]} || 0)) / ($BETA * $T + ($bigram_count{$p}{'<all>'} || 0));
                $sum_weight += $weight[$i];
            }

            # sample one
            my $rand = rand($sum_weight);
            my $value = $weight[0];
            my $i = 0;
            while ($value <= $rand) {
                $value += $weight[++$i];
            }
            $pos[$s][$w] = $candidates[$s][$w][$i];
            
            # update counts
            $emission_count{$pos[$s][$w]}{$word[$s][$w]}++;
            $emission_count{$pos[$s][$w]}{'<all>'}++;
            $bigram_count{$pos[$s][$w-1]}{$pos[$s][$w]}++;
            $bigram_count{$pos[$s][$w-1]}{'<all>'}++;
            $bigram_count{$pos[$s][$w]}{$pos[$s][$w+1]}++;
            $bigram_count{$pos[$s][$w]}{'<all>'}++;
        }
    }
}

# print output
foreach my $s (0 .. $#word) {
    foreach my $w (1 .. $#{$word[$s]}) {
        print "$w\t$word[$s][$w]\t_\t$pos[$s][$w]\n";
    }
    print "\n";
}














    

        



