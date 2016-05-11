#!/usr/bin/env perl

use strict;
use warnings;

my %mapping = ('bg' => 'bul', 'ca' => 'cat', 'cs' => 'ces', 'da' => 'dan', 'de' => 'deu', 'el' => 'ell',
               'en' => 'eng', 'et' => 'est', 'eu' => 'eus', 'fa' => 'fas', 'fi' => 'fin', 'fr' => 'fra',
               'ga' => 'gle', 'he' => 'heb', 'hi' => 'hin', 'hr' => 'hrv', 'hu' => 'hun', 'id' => 'ind',
               'it' => 'ita', 'la' => 'lat', 'no' => 'nor', 'pl' => 'pol', 'pt' => 'por', 'ro' => 'ron',
               'sl' => 'slv', 'es' => 'spa', 'sv' => 'swe', 'ta' => 'tam');
my ($string, $language) = @ARGV;
my $code = $language;
$code =~ s/^([^_]+)_.+$/$1/;
if ($mapping{$code}) {
    $string =~ s/XXX/$mapping{$code}/g;
    $string =~ s/XX/$language/g;
    print "$string\n";
}
else {
    print STDERR "Language $language is unknown.\n";
}
