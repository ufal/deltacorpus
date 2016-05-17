#!/usr/bin/env perl

use strict;
use warnings;

my %mapping = ('ar' => 'ara', 'bg' => 'bul', 'ca' => 'cat', 'cs' => 'ces', 'da' => 'dan', 'de' => 'deu', 'el' => 'ell',
               'en' => 'eng', 'es' => 'spa', 'et' => 'est', 'eu' => 'eus', 'fa' => 'fas', 'fi' => 'fin', 'fr' => 'fra',
               'ga' => 'gle', 'gl' => 'glg', 'he' => 'heb', 'hi' => 'hin', 'hr' => 'hrv', 'hu' => 'hun', 'id' => 'ind',
               'it' => 'ita', 'kk' => 'kaz', 'la' => 'lat', 'lv' => 'lav', 'nl' => 'nld', 'no' => 'nor', 'pl' => 'pol',
               'pt' => 'por', 'ro' => 'ron', 'ru' => 'rus', 'sk' => 'slk', 'sl' => 'slv', 'sv' => 'swe', 'ta' => 'tam',
               'tr' => 'tur');
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
