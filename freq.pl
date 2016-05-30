#!/usr/bin/env perl
# Statistiky značek pro prezentaci v Portoroži.
# Copyright © 2016 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

my %h, %wt, %left, %right;
my $n = 0;
# Remember n previous words and tags. Default n=3 so we can compute neighborhood entropy of the middle word.
my @window;
my @twindow;
while(<>)
{
    next if(m/^\#/);
    next if(m/^\d+-\d/);
    next if(m/^\s*$/);
    my @fields = split(/\t/, $_);
    my $form = lc($fields[1]);
    my $tag = $fields[3];
    next if($form =~ m/^\d+$/ || $tag eq 'PUNCT');
    $h{$form}{count}++;
    $wt{$form}{$tag}++;
    $n++;
    # Sliding window.
    push(@window, $form);
    push(@twindow, $tag);
    if(scalar(@window)>3)
    {
        shift(@window);
        shift(@twindow);
        $left{$window[1]}{$window[0]}++;
        $right{$window[1]}{$window[2]}++;
    }
}

# Compute entropy of left and right neighborhood of each word type.
my %lent, %rent;
my @keys = keys(%h);
foreach my $type (@keys)
{
    my $ntype = $h{$type}{count};
    # Compute entropy of the left neighborhood.
    my $entropy = 0;
    foreach my $neighbor (keys(%{$left{$type}}))
    {
        $entropy -= log( $left{$type}{$neighbor} / $ntype );
    }
    $lent{$type} = $entropy;
    # Compute entropy of the right neighborhood.
    $entropy = 0;
    foreach my $neighbor (keys(%{$right{$type}}))
    {
        $entropy -= log( $right{$type}{$neighbor} / $ntype );
    }
    $rent{$type} = $entropy;
    # Entropy ratio.
    my $er = $rent{$type}!=0 ? $lent{$type}/$rent{$type} : 0;
    $er = 1/$er if($er<1 && $er>0);
    # Entropies of rare words are less interesting.
    $er = 0 if($h{$type}{count}<100);
    $h{$type}{er} = $er;
}

print("Total $n words, excluding numbers and punctuation.\n");
@keys = sort {$h{$b}{er} <=> $h{$a}{er}} (keys(%h));
my $nk = scalar(@keys);
print("Total $nk unique word type – tag pairs.\n");
foreach my $key (@keys)
{
    $h{$key}{rf} = $h{$key}{count} / $n;
    $h{$key}{lf} = log($h{$key}{rf});
    print("$key\t$h{$key}{count}\t$h{$key}{rf}\t$h{$key}{lf}\tlH=$lent{$key}\trH=$rent{$key}\t$h{$key}{er}\n");
}

my @colors =
(
    # lb: lower bound (not strict) of the lf value
    # ub: upper bound (strict) of the lf value
    # color: name of color in LibreOffice
    {'lb' => 0, 'ub' => 4, 'color' => 'Červená 4'},
    {'lb' => 4, 'ub' => 5, 'color' => 'Červená 3'},
    {'lb' => 5, 'ub' => 6, 'color' => 'Oranžová 2'},
    {'lb' => 6, 'ub' => 7, 'color' => 'Žlutá 3'},
    {'lb' => 7, 'ub' => 8, 'color' => 'Žlutozelená 4'},
    {'lb' => 8, 'ub' => 9, 'color' => 'Zelená 5'},
    {'lb' => 9, 'ub' => 10, 'color' => 'Tyrkysová 6'},
    {'lb' => 10, 'ub' => undef, 'color' => 'Modrá 5'}
);
sub get_lfcolor
{
    my $lf = shift;
    $lf = -$lf if($lf < 0);
    if($lf < 4)
    {
        return 0;
    }
    elsif($lf >= 10)
    {
        return 7;
    }
    else
    {
        return int($lf) - 3;
    }
}

# Loop over keys of %wt (word types).
# Take each of its tags separately.
# In a separate hash, whose keys are tags, record number of occurrences of the tag.
# Also add up there lf values of word types it occurred with (times the number of occurrences).
# Compute mean values at the end.
my %tags;
foreach my $type (keys(%wt))
{
    foreach my $tag (keys(%{$wt{$type}}))
    {
        # The present combination of type and tag occurred $wt{$type}{$tag} times.
        $tags{$tag}{count} += $wt{$type}{$tag};
        $tags{$tag}{lfsum} += $wt{$type}{$tag} * $h{$type}{lf};
    }
}
@keys = sort(keys(%tags));
foreach my $key (@keys)
{
    $tags{$key}{rf} = $tags{$key}{count} / $n;
    $tags{$key}{lf} = log($tags{$key}{rf});
    $tags{$key}{avgwordlf} = $tags{$key}{lfsum} / $tags{$key}{count};
}
@keys = sort {$tags{$b}{avgwordlf} <=> $tags{$a}{avgwordlf}} (@keys);
foreach my $key (@keys)
{
    my $color = $colors[get_lfcolor($tags{$key}{avgwordlf})]{color};
    print("$key\t$tags{$key}{count}\t$tags{$key}{rf}\t$tags{$key}{lf}\t$tags{$key}{avgwordlf}\t$color\n");
}

# Look at all word types falling into a certain range of values (color).
# What proportion of tokens with this color is ADP, and what proportions get the other tags?
my %color2tag;
foreach my $type (keys(%wt))
{
    my $color = $colors[get_lfcolor($h{$type}{lf})]{color};
    foreach my $tag (keys(%{$wt{$type}}))
    {
        $color2tag{$color}{$tag} += $wt{$type}{$tag};
    }
}
foreach my $colorrecord (@colors)
{
    my $color = $colorrecord->{color};
    my $ct = $color2tag{$color};
    my $nct = 0;
    my @tags = sort {$ct->{$b} <=> $ct->{$a}} (keys(%{$ct}));
    foreach my $tag (@tags)
    {
        $nct += $ct->{$tag};
    }
    print("$color =>");
    foreach my $tag (@tags)
    {
        my $percentage = sprintf("%d", $ct->{$tag} / $nct * 100 + 0.5);
        print(" $tag ($percentage%)");
    }
    print("\n");
}
print("OVERALL =>");
foreach my $tag (sort {$tags{$b}{count} <=> $tags{$a}{count}} (keys(%tags)))
{
    my $percentage = sprintf("%d", $tags{$tag}{rf} * 100 + 0.5);
    print(" $tag ($percentage%)");
}
print("\n");

# Investigate correlation between word length and tag.
my %length2tag;
foreach my $type (keys(%wt))
{
    my $length = length($type);
    $length = 8 if($length > 8);
    foreach my $tag (keys(%{$wt{$type}}))
    {
        $length2tag{$length}{$tag} += $wt{$type}{$tag};
    }
}
print("\nWord length => part of speech\n");
for(my $l = 1; $l <= 8; $l++)
{
    my $lt = $length2tag{$l};
    my $nlt = 0;
    my @tags = sort {$lt->{$b} <=> $lt->{$a}} (keys(%{$lt}));
    foreach my $tag (@tags)
    {
        $nlt += $lt->{$tag};
    }
    print("length $l =>");
    foreach my $tag (@tags)
    {
        my $percentage = sprintf("%d", $lt->{$tag} / $nlt * 100 + 0.5);
        print(" $tag ($percentage%)");
    }
    print("\n");
}
