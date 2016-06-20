#!/usr/bin/env perl
# Visits every file (language) in the current folder (prepared release of Deltacorpus).
# Counts tokens using wc_conll.pl.
# Saves the number of tokens in the table of languages. (WARNING! It considers only those languages that have already been in the previous version.)

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
use dzsys;

open(LANGUAGES, '../LANGUAGES.txt') or die("Cannot read ../LANGUAGES.txt: $!");
my @files = dzsys::get_files('.');
foreach my $file (@files)
{
    if($file =~ m/^(.+)\.txt\.gz$/)
    {
        my $language = $1;
        my $response = `gunzip -c $file | wc_conll.pl`;
        if($response =~ m/, (\d+) tokens/)
        {
            $ltok{$language} = $1;
            print STDERR ("$language\t$response");
        }
    }
}
my $n = 0;
while(<LANGUAGES>)
{
    if(m/^([a-z]{3})( \t.+?\t )\d+\s*$/ && exists($ltok{$1}))
    {
        printf("$1$2%6d\n", $ltok{$1});
        $n += $ltok{$1};
    }
    else
    {
        print;
    }
}
close(LANGUAGES);
print("TOTAL\t\t$n\n");
