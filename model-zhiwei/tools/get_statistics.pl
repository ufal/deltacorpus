#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";

my $MAX_WORDS = 1000000000000;
my $LANG_CODE = 'xx';
my $BIG_CORPUS = '';
my $TRAINING_FILE = '';
my $INCLUDE_OOV = 0;

GetOptions ("train=s"      => \$TRAINING_FILE,
            "big-corpus=s" => \$BIG_CORPUS,
            "language=s"   => \$LANG_CODE,
            "max-words=i"  => \$MAX_WORDS,
            "include-oov"  => \$INCLUDE_OOV,
           );

my %count;
my %appeared;

print STDERR "Reading CoNLL...\n";
open (CONLL, "<:utf8", $TRAINING_FILE) or die;
while (<CONLL>) {
    chomp;
    if ($_ =~ /^\d+\t/) {
        my ($ord, $form, $lemma, $pos) = split /\t/, $_;
        $count{$pos}{lc($form)}++;
        $appeared{lc($form)} = 1;
    }
}
close CONLL;

my $total_count = 0;
my %word_count;
my %prev_count;
my %next_count;
my %between_count;
my %between_count_total;
my %prevnext_count;
my %prevnext_count_total;
my %after_punc_count;
my %after_num_count;
my %in_short_count;
my %root_suffix_count;
my %root_count;
my %suffix_count;

my $line_counter = 0;
print STDERR "Counting W2C:";
open (W2C, "<:utf8", $BIG_CORPUS) or die;
while (<W2C>) {
    last if $total_count > $MAX_WORDS;
    chomp;
    my $line = $_;
    $line_counter++;
    print STDERR " $line_counter" if $line_counter % 10000 == 0;
    # tokenize
    $line =~ s/([^[:alnum:]])/ $1 /g;
    $line =~ s/\s+/ /g;
    $line =~ s/^\s+//g;
    $line =~ s/\s+$//g;
    my @tokens;
    my $snt_cnt = 0;
    my $wrd_cnt = 0;
    my $last_tok = '<s>';
    my @all_tokens = split /\s/, $line;
    $total_count += scalar @all_tokens;
    foreach my $tok (@all_tokens) {
        if ($tok =~ /^[[:upper:]]/ && $last_tok =~ /^[\.,:;!\?"]$/) {
            $snt_cnt++;
            $wrd_cnt = 0;
        }
        $tokens[$snt_cnt][$wrd_cnt++] = lc($tok);
        $last_tok = $tok;
    }
    foreach my $s (0 .. $#tokens) {
        foreach my $i (0 .. $#{$tokens[$s]}) {
            my $prev = $i == 0 ? '<s>' : $tokens[$s][$i-1];
            my $next = $i == $#{$tokens[$s]} ? '<s>' : $tokens[$s][$i+1];
            $between_count{"$prev $next"}{$tokens[$s][$i]}++;
            $between_count_total{"$prev $next"}++;
            foreach my $suflen (0 .. 4) {
                my $root = substr $tokens[$s][$i], 0, -$suflen;
                my $suffix = substr $tokens[$s][$i], -$suflen, $suflen;
                if (length($root) > 3) {
                    $root_suffix_count{$root}{$suffix}++;
                    $root_count{$root}++;
                    $suffix_count{$suffix}++
                }
            }
            if ($appeared{$tokens[$s][$i]}) {
                $word_count{$tokens[$s][$i]}++;
                $prev_count{$tokens[$s][$i]}{$prev}++;
                $next_count{$tokens[$s][$i]}{$next}++;
                $prevnext_count{$tokens[$s][$i]}{"$prev $next"}++;
                if ($prev =~ /^[^[:alnum:]]$/) {
                    $after_punc_count{$tokens[$s][$i]}++;
                }
                elsif ($prev =~ /^\d+$/) {
                    $after_num_count{$tokens[$s][$i]}++;
                }
                if ((scalar @{$tokens[$s]}) <= 5) {
                    $in_short_count{$tokens[$s][$i]}++;
                }
            }
        }
    }
}
close W2C;

my @table;
print STDERR "\nComputing statistics:";
foreach my $pos (keys %count) {
    print STDERR " $pos";
    foreach my $word (keys %{$count{$pos}}) {
        my $length = length($word);
        my $is_num = $word =~ /^\d+$/ ? 1 : 0;
        my $is_punc = $word =~ /^[^[:alnum:]]+$/ ? 1 : 0;
        if (!$word_count{$word}) {
            if ($INCLUDE_OOV) {
                print "$pos\t$LANG_CODE\t$word\t$count{$pos}{$word}\t$length\t-100\t-100\t-100\t";
                print "-100\t$is_num\t$is_punc\t-100\t-100\t-100\t-100\n";
            }
            next;
        }
        # entropy of the previous words
        my $prev_entropy = 0;
        foreach my $prev_word (keys %{$prev_count{$word}}) {
            my $prob = $prev_count{$word}{$prev_word} / $word_count{$word};
            $prev_entropy -= $prob * log($prob) / log(2);
        }
        # entropy of the next word
        my $next_entropy = 0;
        foreach my $next_word (keys %{$next_count{$word}}) {
            my $prob = $next_count{$word}{$next_word} / $word_count{$word};
            $next_entropy -= $prob * log($prob) / log(2);
        }
        # entopy of the substituting words
        my $substituting_entropy = 0;
        foreach my $prevnext_words (keys %{$prevnext_count{$word}}) {
            my $partial_entropy = 0;
            foreach my $between_word (keys %{$between_count{$prevnext_words}}) {
                my $prob = $between_count{$prevnext_words}{$between_word} / $between_count_total{$prevnext_words};
                $partial_entropy -= $prob * log($prob) / log(2);
            }
            $substituting_entropy += $partial_entropy * $prevnext_count{$word}{$prevnext_words};
        }
        $substituting_entropy /= $word_count{$word};

        # suffix entropy given the root
        my $best_score = 0;
        my $best_suflen = 0;
        my $best_root = '';
        foreach my $suflen (0 .. 4) {
            my $root = substr $word, 0, -$suflen;
            my $suffix = substr $word, -$suflen, $suflen;
            my $score = $root_count{$root} * $suffix_count{$suffix};
            if ($score > $best_score && length($root) > 3) {
                $best_score = $score;
                $best_suflen = $suflen;
                $best_root = $root;
            }
        }
        my $suffix_entropy = 0;
        foreach my $suffix (keys %{$root_suffix_count{$best_root}}) {
            my $prob = $root_suffix_count{$best_root}{$suffix} / $root_count{$best_root};
            $suffix_entropy -= $prob * log($prob) / log(2);
        }
        my $freq = log($word_count{$word} / $total_count) / log(2);
        my $after_punc = log((($after_punc_count{$word} || 0) + 0.1) / $word_count{$word}) / log(2);
        my $after_num = log((($after_num_count{$word} || 0) + 0.1) / $word_count{$word}) / log(2);
        my $inshort = ($in_short_count{$word} || 0) / $word_count{$word};
        print "$pos\t$LANG_CODE\t$word\t$count{$pos}{$word}\t$length\t$freq\t$prev_entropy\t$next_entropy\t";
        print "$substituting_entropy\t$is_num\t$is_punc\t$after_punc\t$after_num\t$inshort\t$suffix_entropy\n";
    }
}

