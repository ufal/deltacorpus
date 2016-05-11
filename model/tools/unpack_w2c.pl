#!/usr/bin/perl

use strict;
use warnings;

my %code3 = (ar => 'ara', bg => 'bul', bn => 'ben', ca => 'cat', cs => 'ces', da => 'dan', de => 'deu', el => 'ell', en => 'eng',
             es => 'spa', et => 'est', eu => 'eus', fa => 'fas', fi => 'fin', hi => 'hin', hu => 'hun', it => 'ita', ja => 'jpn',
             la => 'lat', nl => 'nld', pt => 'por', ro => 'ron', ru => 'rus', sk => 'slk', sl => 'slv', sv => 'swe', ta => 'tam',
             te => 'tel', tr => 'tur');

my ($language, $lines, $output) = @ARGV;
if (!$code3{$language}) {
    exit "CODE3 for language $language is not in the list.";
}

system "zcat /net/data/W2C/W2C_WEB/2011-08/$code3{$language}.txt.gz | head -$lines > $output";

