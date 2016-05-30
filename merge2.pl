#!/usr/bin/env perl
# Slije data označkovaná deltaggerem s původním CoNLL souborem, aby bylo možné je použít pro delexikalizovaný parsing.
# Copyright © 2016 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

my $origfile = 'data/ud/train/cs.conll';
my $deltafile = 'data/cpredicted/c7-cs.conll'; ###!!! Nemáme zvlášť označkovaná trénovací i testovací data!
open(OF, $origfile) or die("Cannot read $origfile: $!");
open(DF, $deltafile) or die("Cannot read $deltafile: $!");
while(<OF>)
{
    my $ofline = $_;
    my $dfline = <DF>;
    my @ofields = split(/\t/, $ofline);
    my @dfields = split(/\t/, $dfline);
    # Delexicalized data: no FORM and no LEMMA.
    $ofields[1] = '_';
    $ofields[2] = '_';
    # UPOS in deltafile is gold-standard tag, XPOS is predicted tag. We want the predicted tag.
    $ofields[3] = $dfields[4];
    $ofields[4] = $dfields[4];
    # There are no morphological features.
    $ofields[5] = '_';
    # Keep the remaining fields (HEAD, DEPREL, DEPS and MISC) from the original file.
    $ofline = join("\t", @ofields);
    print($ofline);
}
close(OF);
close(DF);
