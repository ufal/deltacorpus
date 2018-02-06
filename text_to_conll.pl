#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";

my $MAX_TOKENS = 1000000;
my $token_cnt = 0;

while (<>)
{
    chomp;
    my $line = $_;
    # Tentatively split the line on existing whitespace only.
    # We will later compare this with the tokenization that takes punctuation into account, and save the points where there were no spaces.
    my @pretokens = split(/\s+/, $line);
    # tokenize
    $line =~ s/(\w+)/ $1 /g;
    $line =~ s/([^\s\w]+)/ $1 /g;
    $line =~ s/([^\s\w\d])/ $1 /g;
    $line =~ s/\s+/ /g;
    $line =~ s/^\s+//g;
    $line =~ s/\s+$//g;
    my @tokens = split /\s/, $line;
    # Compare tokens to pretokens. Identify places where we inserted a space.
    my @nospaceafter;
    if(scalar(@tokens) != scalar(@pretokens))
    {
        if(scalar(@tokens) < scalar(@pretokens))
        {
            die('Merger of tokens was not expected');
        }
        my $j = 0;
        for(my $i = 0; $i<=$#tokens;)
        {
            if($tokens[$i] eq $pretokens[$j])
            {
                $nospaceafter[$i] = 0;
                $i++;
                $j++;
            }
            # If token is not identical to pretoken then token should be a prefix of pretoken.
            elsif($pretokens[$j] =~ s/^\Q$tokens[$i]\E(.+)$/$1/)
            {
                $nospaceafter[$i] = 1;
                $i++;
            }
            # We are not supposed to ever come here.
            else
            {
                die("Unexpected pretoken '$pretokens[$j]' and token '$tokens[$i]'");
            }
        }
    }
    foreach my $i (0 .. $#tokens)
    {
        my $ord = $i + 1;
        my $misc = $nospaceafter[$i] ? 'SpaceAfter=No' : '_';
        print "$ord\t$tokens[$i]\t_\t_\t_\t_\t_\t_\t_\t$misc\n";
        $token_cnt++;
    }
    print "\n";
    last if $token_cnt > $MAX_TOKENS;
}

