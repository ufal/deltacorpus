#!/usr/bin/perl

use strict;
use warnings;

my @LANGUAGE  = qw(bg  ca  cs  de  el  en  hi  hu  it  ja  pt  ru  sv  ta  tr);
my @LANG_LONG = qw(bul cat ces deu ell eng hin hun ita jpn por rus swe tam tur);
#my @LANGUAGE  = qw(cs  en);
#my @LANG_LONG = qw(ces eng);

foreach my $i (0 .. $#LANGUAGE) {
    system "zcat /net/data/hamledt/$LANGUAGE[$i]/stanford/train/*.conll.gz | head -50000 > data/train-conll-50k/$LANGUAGE[$i].conll";
    system "zcat /net/data/W2C/W2C_WEB/2011-08/$LANG_LONG[$i].txt.gz | head -1000000 > data/w2c-1Mlines/$LANGUAGE[$i].txt";
    system "echo \"./get_statistics.pl data/train-conll-50k/$LANGUAGE[$i].conll data/w2c-1Mlines/$LANGUAGE[$i].txt 0 > data/train9-50k/$LANGUAGE[$i].data 2> $LANGUAGE[$i]-train-50k.err\" > $LANGUAGE[$i]-run.sh";
    system "qsub -hard -l mf=30g -l act_mem_free=30g -cwd -o /dev/null -e /dev/null $LANGUAGE[$i]-run.sh";
}

