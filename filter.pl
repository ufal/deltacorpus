#!/usr/bin/env perl
# Reads a corpus in a vertical format (similar to CoNLL; the second column contains word forms).
# Identifies words that do not belong to the language because they contain alien characters.
# Copyright © 2016 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

my %l2s =
(
    'afr' => 'Latin',
    'als' => 'Latin', 'gsw' => 'Latin', # 'als' is used in W2C but it is not the correct code; in Deltacorpus we use 'gsw' instead.
    'amh' => 'Ethiopic',
    'ara' => 'Arabic',
    'arg' => 'Latin',
    'arz' => 'Arabic',
    'ast' => 'Latin',
    'aze' => 'Latin',
    'bcl' => 'Latin',
    'bel' => 'Cyrillic',
    'ben' => 'Bengali',
    'bos' => 'Latin',
    'bpy' => 'Bengali',
    'bre' => 'Latin',
    'bul' => 'Cyrillic',
    'cat' => 'Latin',
    'ceb' => 'Latin',
    'ces' => 'Latin',
    'chv' => 'Cyrillic|Latin', # They take letters with diacritics from Latin. This will not work, there is a hack below that fixes it.
    'cos' => 'Latin',
    'cym' => 'Latin',
    'dan' => 'Latin',
    'deu' => 'Latin',
    'diq' => 'Latin',
    'ell' => 'Greek',
    'eng' => 'Latin',
    'epo' => 'Latin',
    'est' => 'Latin',
    'eus' => 'Latin',
    'fao' => 'Latin',
    'fas' => 'Arabic',
    'fin' => 'Latin',
    'fra' => 'Latin',
    'fry' => 'Latin',
    'gan' => 'Han',
    'gla' => 'Latin',
    'gle' => 'Latin',
    'glg' => 'Latin',
    'glk' => 'Arabic',
    'guj' => 'Gujarati',
    'hat' => 'Latin',
    'hbs' => 'Latin',
    'heb' => 'Hebrew',
    'hif' => 'Latin',
    'hin' => 'Devanagari',
    'hrv' => 'Latin',
    'hsb' => 'Latin',
    'hun' => 'Latin',
    'hye' => 'Armenian',
    'ido' => 'Latin',
    'ina' => 'Latin',
    'ind' => 'Latin',
    'isl' => 'Latin',
    'ita' => 'Latin',
    'jav' => 'Latin',
    'jpn' => 'Kana', ###!!! and Han!
    'kan' => 'Kannada',
    'kat' => 'Georgian',
    'kaz' => 'Cyrillic',
    'kor' => 'Hangul',
    'kur' => 'Latin',
    'lat' => 'Latin',
    'lav' => 'Latin',
    'lim' => 'Latin',
    'lit' => 'Latin',
    'lmo' => 'Latin',
    'ltz' => 'Latin',
    'mal' => 'Malayalam',
    'mar' => 'Devanagari',
    'mkd' => 'Cyrillic',
    'mlg' => 'Latin',
    'mon' => 'Cyrillic',
    'mri' => 'Latin',
    'msa' => 'Latin',
    'mya' => 'Myanmar',
    'nap' => 'Latin',
    'nds' => 'Latin',
    'nep' => 'Devanagari',
    'new' => 'Devanagari',
    'nld' => 'Latin',
    'nno' => 'Latin',
    'nor' => 'Latin',
    'oci' => 'Latin',
    'oss' => 'Cyrillic',
    'pam' => 'Latin',
    'pms' => 'Latin',
    'pnb' => 'Arabic',
    'pol' => 'Latin',
    'por' => 'Latin',
    'que' => 'Latin',
    'ron' => 'Latin',
    'rus' => 'Cyrillic',
    'sah' => 'Cyrillic',
    'scn' => 'Latin',
    'sco' => 'Latin',
    'slk' => 'Latin',
    'slv' => 'Latin',
    'spa' => 'Latin',
    'sqi' => 'Latin',
    'srp' => 'Cyrillic',
    'sun' => 'Latin',
    'swa' => 'Latin',
    'swe' => 'Latin',
    'tam' => 'Tamil',
    'tat' => 'Cyrillic',
    'tel' => 'Telugu',
    'tgk' => 'Cyrillic',
    'tgl' => 'Latin',
    'tha' => 'Thai',
    'tur' => 'Latin',
    'ukr' => 'Cyrillic',
    'urd' => 'Arabic',
    'uzb' => 'Latin',
    'vec' => 'Latin',
    'vie' => 'Latin',
    'vol' => 'Latin',
    'war' => 'Latin',
    'wln' => 'Latin',
    'yid' => 'Hebrew',
    'yor' => 'Latin',
    'zho' => 'Han'
);

my $language = shift(@ARGV); # ISO 639-3 language code
my $script = $l2s{$language}; # for \p{Script=$script} in regular expressions
die("Usage: $0 langcode") if(!defined($language));
die("Unknown language '$language'") if(!defined($script));

my $paragraph = '';
my $n = 0;
my $nbad = 0;
while(<>)
{
    $paragraph .= $_;
    # Empty line denotes the end of paragraph.
    if($_ =~ m/^\s*$/)
    {
        # Skip paragraphs with too many alien words and non-words.
        unless($nbad >= $n/2)
        {
            print($paragraph);
        }
        $paragraph = '';
        $n = 0;
        $nbad = 0;
    }
    else
    {
        $n++;
        # Examine tokens.
        my @fields = split(/\t/, $_);
        my $form = $fields[1];
        my $l1 = length($form);
        # Remove characters that are not in the required script.
        # The Chuvash data combine Cyrillic and Latin scripts, taking letters with diacritics from Latin.
        # (This seems to be a bug: the corresponding letters exist in Cyrillic Unicode.)
        # We should normalize the data before filtering and further processing:
        # Chuvash diacritics Latin --> Cyrillic
        # Ç         199   00C7    L       LATIN CAPITAL LETTER C WITH CEDILLA
        # ç         231   00E7    L       LATIN SMALL LETTER C WITH CEDILLA
        # Ă         258   0102    L       LATIN CAPITAL LETTER A WITH BREVE
        # ă         259   0103    L       LATIN SMALL LETTER A WITH BREVE
        # Ĕ         276   0114    L       LATIN CAPITAL LETTER E WITH BREVE
        # ĕ         277   0115    L       LATIN SMALL LETTER E WITH BREVE
        # Ҫ        1194   04AA    L       CYRILLIC CAPITAL LETTER ES WITH DESCENDER
        # ҫ        1195   04AB    L       CYRILLIC SMALL LETTER ES WITH DESCENDER
        # Ӑ        1232   04D0    L       CYRILLIC CAPITAL LETTER A WITH BREVE
        # ӑ        1233   04D1    L       CYRILLIC SMALL LETTER A WITH BREVE
        # Ӗ        1238   04D6    L       CYRILLIC CAPITAL LETTER IE WITH BREVE
        # ӗ        1239   04D7    L       CYRILLIC SMALL LETTER IE WITH BREVE
        ###!!! tr/\x{C7}\x{E7}\x{102}\x{103}\x{114}\x{115}/\x{4AA}\x{4AB}\x{4D0}\x{4D1}\x{4D6}\x{4D7}/;
        if($language eq 'chv')
        {
            $form =~ s/[^\p{Cyrillic}\p{Latin}]//g;
        }
        else
        {
            $form =~ s/\P{Script=$script}//g;
        }
        my $l2 = length($form);
        # The token is "bad" if it contains any bad character (i.e. punctuation and numbers are also bad).
        if($l2 < $l1)
        {
            $nbad++;
            #print STDERR ("$fields[1]\n");
        }
    }
}
